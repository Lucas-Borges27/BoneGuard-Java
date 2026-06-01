package br.com.fiap.boneguard.external_interface.feign;

import br.com.fiap.boneguard.enums.ResultadoIA;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

@Component
public class VisionServiceFallback implements VisionServiceClient {

    private static final Logger logger = LoggerFactory.getLogger(VisionServiceFallback.class);

    @Override
    public VisionResponse analisarRadiografia(MultipartFile imagem) {
        logger.warn("API de visão offline — retornando resultado mock");
        return new VisionResponse(ResultadoIA.NORMAL, 0.5, 25.0);
    }
}
