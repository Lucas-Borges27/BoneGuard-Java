package br.com.fiap.boneguard.dto.evolucao;

import br.com.fiap.boneguard.enums.NivelAtividade;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record EvolucaoRequest(
        @NotNull Long pacienteId,
        @NotNull @Positive Double pesoAtual,
        @NotNull NivelAtividade nivelAtividadeAtual,
        @Size(max = 1000) String observacoes
) {
}
