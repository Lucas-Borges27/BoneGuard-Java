package br.com.fiap.boneguard.external_interface.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

@FeignClient(name = "vision-service", url = "${vision.service.url}", fallback = VisionServiceFallback.class)
public interface VisionServiceClient {

    @PostMapping(value = "/analisar-radiografia", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    VisionResponse analisarRadiografia(@RequestPart("imagem") MultipartFile imagem);
}
