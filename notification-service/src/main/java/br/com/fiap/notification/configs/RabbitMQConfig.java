package br.com.fiap.notification.configs;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    public static final String QUEUE_ALERTAS = "boneguard.alertas";
    public static final String EXCHANGE_ALERTAS = "boneguard.exchange";
    public static final String ROUTING_KEY_ALERTAS = "alerta.alto";

    @Bean
    public Queue alertasQueue() {
        return new Queue(QUEUE_ALERTAS, true);
    }

    @Bean
    public DirectExchange alertasExchange() {
        return new DirectExchange(EXCHANGE_ALERTAS);
    }

    @Bean
    public Binding alertasBinding(Queue alertasQueue, DirectExchange alertasExchange) {
        return BindingBuilder.bind(alertasQueue).to(alertasExchange).with(ROUTING_KEY_ALERTAS);
    }

    @Bean
    public MessageConverter messageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(messageConverter());
        return template;
    }
}
