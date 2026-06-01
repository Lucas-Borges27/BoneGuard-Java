package br.com.fiap.notification.consumer;

import br.com.fiap.notification.configs.RabbitMQConfig;
import br.com.fiap.notification.dto.AlertaEvent;
import br.com.fiap.notification.entities.Alerta;
import br.com.fiap.notification.exception.AlertaProcessingException;
import br.com.fiap.notification.repositories.AlertaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class AlertaConsumer {

    private static final Logger logger = LoggerFactory.getLogger(AlertaConsumer.class);

    private final AlertaRepository alertaRepository;

    public AlertaConsumer(AlertaRepository alertaRepository) {
        this.alertaRepository = alertaRepository;
    }

    @RabbitListener(queues = RabbitMQConfig.QUEUE_ALERTAS)
    public void consumir(AlertaEvent event) {
        logger.info("Mensagem recebida da fila boneguard.alertas — paciente_id={} classificacao={}",
                event.pacienteId(), event.classificacao());

        try {
            Alerta alerta = new Alerta();
            alerta.setPacienteId(event.pacienteId());
            alerta.setAvaliacaoId(event.avaliacaoId());
            alerta.setMensagem(event.mensagem());
            alerta.setStatus("PENDENTE");
            alerta.setDataCriacao(event.dataCriacao() != null ? event.dataCriacao() : LocalDate.now());

            alertaRepository.save(alerta);
            logger.info("Alerta persistido com sucesso para paciente_id={}", event.pacienteId());

        } catch (Exception e) {
            logger.error("Erro ao processar alerta para paciente_id={}: {}", event.pacienteId(), e.getMessage(), e);
            throw new AlertaProcessingException("Falha ao persistir alerta: " + e.getMessage(), e);
        }
    }
}
