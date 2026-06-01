package br.com.fiap.boneguard.dto.paciente;

import br.com.fiap.boneguard.enums.NivelAtividade;
import br.com.fiap.boneguard.enums.Sexo;
import jakarta.validation.constraints.*;

public record PacienteRequest(
        @NotBlank @Size(max = 150) String nome,
        @NotNull @Min(1) @Max(130) Integer idade,
        @NotNull Sexo sexo,
        @NotNull @Positive Double peso,
        @NotNull Boolean historicoFamiliar,
        @NotNull NivelAtividade nivelAtividade,
        @NotNull Boolean alimentacaoCalcio
) {
}
