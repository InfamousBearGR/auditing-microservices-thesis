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
        eventPublisher = kafkaReceiver.receive()
                .filter(record -> record.value() != null)
                .map(consumerRecord -> {
                    EventBaseModel event = consumerRecord.value()
                    event.setSourceTopic(consumerRecord.topic())
                    return event
                })
                .replay()
        eventPublisher.connect()
    }

    ConnectableFlux<EventBaseModel> getEventPublisher() {
        return eventPublisher
    }
}
