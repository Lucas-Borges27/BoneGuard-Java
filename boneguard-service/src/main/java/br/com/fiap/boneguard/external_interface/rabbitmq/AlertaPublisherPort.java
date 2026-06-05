package br.com.fiap.boneguard.external_interface.rabbitmq;

public interface AlertaPublisherPort {
    void publicar(AlertaEvent event);
}
