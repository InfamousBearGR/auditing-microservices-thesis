package sseBridge.kafka


import jakarta.annotation.PostConstruct
import org.springframework.stereotype.Service
import reactor.core.publisher.ConnectableFlux
import reactor.kafka.receiver.KafkaReceiver
import sseBridge.event.EventBaseModel

@Service
class KafkaService {
    private final KafkaReceiver<String, EventBaseModel> kafkaReceiver

    private ConnectableFlux<EventBaseModel> eventPublisher

    KafkaService(KafkaReceiver<String, EventBaseModel> kafkaReceiver) {
        this.kafkaReceiver = kafkaReceiver
    }

    @PostConstruct
    void init() {
        // One shared, HOT stream for all SSE clients: a client receives the events
        // published while it is connected (missed events are recovered through the
        // History API by change_id). publish() — not replay(): an unbounded replay()
        // kept every event since start-up in memory and re-sent the whole history to
        // each new or reconnecting client.
        eventPublisher = kafkaReceiver.receive()
                .map(consumerRecord -> {
                    // Commit the bridge's consumer position (periodically, by reactor-kafka)
                    // so a restarted bridge resumes where it stopped instead of re-reading
                    // the topics from the earliest offset.
                    consumerRecord.receiverOffset().acknowledge()
                    return consumerRecord
                })
                .filter(record -> record.value() != null)
                .map(consumerRecord -> {
                    EventBaseModel event = consumerRecord.value()
                    event.setSourceTopic(consumerRecord.topic())
                    return event
                })
                .publish()
        eventPublisher.connect()
    }

    ConnectableFlux<EventBaseModel> getEventPublisher() {
        return eventPublisher
    }
}
