package br.com.fiap.boneguard.external_interface.rabbitmq;

import java.io.Serializable;
import java.time.LocalDate;

public record AlertaEvent(
        Long pacienteId,
        String pacienteNome,
        Long avaliacaoId,
        Double scoreRisco,
        String classificacao,
        String mensagem,
        LocalDate dataCriacao
) implements Serializable {
}
