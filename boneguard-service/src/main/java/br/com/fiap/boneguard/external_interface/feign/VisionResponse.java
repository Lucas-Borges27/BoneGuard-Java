package br.com.fiap.boneguard.external_interface.feign;

import br.com.fiap.boneguard.enums.ResultadoIA;

public record VisionResponse(
        ResultadoIA classificacao,
        Double confianca,
        Double scoreRisco
) {
}
