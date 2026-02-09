package sseBridge.controller

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.MediaType
import org.springframework.http.codec.ServerSentEvent
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import reactor.core.publisher.Flux
import sseBridge.event.EventBaseModel
import sseBridge.event.EventType
import sseBridge.kafka.KafkaService

import java.time.Duration

@RestController
class StreamController {

    private static final Logger logger = LoggerFactory.getLogger(StreamController.class)

    private final KafkaService kafkaService

    StreamController(KafkaService kafkaService) {
        this.kafkaService = kafkaService
    }

    private static ServerSentEvent<EventBaseModel> clientEventToServerSentEvent(EventBaseModel event) {
        event.setTimestamp(System.currentTimeMillis())
        return ServerSentEvent.<EventBaseModel>builder()
                .data(event)
                .build()
    }

    private static ServerSentEvent<EventBaseModel> toHeartBeatServerSentEvent() {
        EventBaseModel heartBeat = new EventBaseModel()
        heartBeat.setEventType(EventType.HEARTBEAT)
        heartBeat.setTimestamp(System.currentTimeMillis())
        return clientEventToServerSentEvent(heartBeat)
    }

    @GetMapping(path = "/stream/{tableName}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    Flux<ServerSentEvent<EventBaseModel>> streamChanges(@PathVariable("tableName") String tableName) {
        Flux<ServerSentEvent<EventBaseModel>> heartbeatStream = Flux.interval(Duration.ofSeconds(10))
                .map(sequence -> toHeartBeatServerSentEvent())

        logger.info("[STARTED] for table: {}", tableName)

        return kafkaService.getEventPublisher()
                .filter(event -> {
                    String topic = event.getSourceTopic()
                    return topic != null && topic.endsWith("." + tableName)
                })
                .map(this::clientEventToServerSentEvent)
                .mergeWith(heartbeatStream) // heart-beat to keep connection alive
                .doOnSubscribe(subscription -> logger.info("[ON_SUBSCRIBE]"))
                .doOnCancel(() -> logger.info("[ON_CANCEL]"))
                .doOnError(e -> logger.error("[ON_ERROR= {}]", e.message))
                .doFinally(signalType -> logger.info("[FINALLY] [SIGNAL_TYPE= {}]", signalType.name()))
    }
}
