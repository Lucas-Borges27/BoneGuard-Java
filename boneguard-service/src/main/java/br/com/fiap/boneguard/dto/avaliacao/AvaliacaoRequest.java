package br.com.fiap.boneguard.dto.avaliacao;

import jakarta.validation.constraints.*;

public record AvaliacaoRequest(
        @NotNull Long pacienteId,
        @NotNull @DecimalMin("0.0") @DecimalMax("100.0") Double scoreRisco
) {
}
