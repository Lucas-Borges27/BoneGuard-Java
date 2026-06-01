package br.com.fiap.boneguard.dto.auth;

import br.com.fiap.boneguard.enums.NivelAtividade;
import br.com.fiap.boneguard.enums.Sexo;
import jakarta.validation.constraints.*;

public record RegisterRequest(
        @NotBlank @Email String email,
        @NotBlank @Size(min = 6) String senha,
        @NotBlank @Size(max = 150) String nome,
        @NotNull @Min(1) @Max(130) Integer idade,
        @NotNull Sexo sexo,
        @NotNull @DecimalMin("0.1") Double peso,
        Boolean historicoFamiliar,
        NivelAtividade nivelAtividade,
        Boolean alimentacaoCalcio
) {
}
