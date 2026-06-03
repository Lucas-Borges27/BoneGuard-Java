package br.com.fiap.boneguard.external_interface.rabbitmq;

import br.com.fiap.boneguard.configs.RabbitMQConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;

@Component
public class AlertaPublisher {

    private static final Logger logger = LoggerFactory.getLogger(AlertaPublisher.class);

    private final RabbitTemplate rabbitTemplate;

    public AlertaPublisher(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void publicar(AlertaEvent event) {
        try {
            logger.info("Publicando AlertaEvent na fila {} para paciente id={}", RabbitMQConfig.QUEUE_ALERTAS, event.pacienteId());
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EXCHANGE_ALERTAS,
                    RabbitMQConfig.ROUTING_KEY_ALERTAS,
                    event
            );
        } catch (AmqpException e) {
            logger.warn("RabbitMQ indisponível — alerta não publicado para paciente id={}: {}", event.pacienteId(), e.getMessage());
        }
    }
}
