package br.com.fiap.boneguard.controller;

import br.com.fiap.boneguard.dto.radiografia.RadiografiaResponse;
import br.com.fiap.boneguard.entities.Radiografia;
import br.com.fiap.boneguard.service.RadiografiaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/radiografias")
@Tag(name = "Radiografias", description = "Upload e análise de radiografias por IA")
@SecurityRequirement(name = "bearerAuth")
public class RadiografiaController {

    private static final Logger logger = LoggerFactory.getLogger(RadiografiaController.class);

    private final RadiografiaService radiografiaService;

    public RadiografiaController(RadiografiaService radiografiaService) {
        this.radiografiaService = radiografiaService;
    }

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Analisar radiografia", description = "Envia imagem para a API de visão e persiste o resultado da análise de IA")
    public ResponseEntity<RadiografiaResponse> upload(
            @RequestParam("avaliacaoId") Long avaliacaoId,
            @RequestParam("imagem") MultipartFile imagem) {
        logger.info("Recebendo upload de radiografia para avaliacao_id={}", avaliacaoId);
        Radiografia radiografia = radiografiaService.analisar(avaliacaoId, imagem);
        RadiografiaResponse response = RadiografiaResponse.from(radiografia);
        adicionarLinks(response);
        URI location = ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/radiografias/{id}").buildAndExpand(radiografia.getId()).toUri();
        return ResponseEntity.created(location).body(response);
    }

    private void adicionarLinks(RadiografiaResponse response) {
        response.add(linkTo(methodOn(AvaliacaoController.class).buscar(response.getAvaliacaoId())).withRel("avaliacao"));
        response.add(linkTo(methodOn(PlanoSaudeController.class).gerarPlanos(response.getAvaliacaoId())).withRel("gerar-planos"));
    }
}
