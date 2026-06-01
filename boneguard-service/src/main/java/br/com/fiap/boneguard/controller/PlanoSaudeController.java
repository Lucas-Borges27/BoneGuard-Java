package br.com.fiap.boneguard.controller;

import br.com.fiap.boneguard.dto.plano.PlanoResponse;
import br.com.fiap.boneguard.service.PlanoSaudeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/planos")
@Tag(name = "Planos de Saúde", description = "Planos personalizados de exercício e nutrição gerados por IA")
@SecurityRequirement(name = "bearerAuth")
public class PlanoSaudeController {

    private static final Logger logger = LoggerFactory.getLogger(PlanoSaudeController.class);

    private final PlanoSaudeService planoSaudeService;

    public PlanoSaudeController(PlanoSaudeService planoSaudeService) {
        this.planoSaudeService = planoSaudeService;
    }

    @GetMapping("/paciente/{pacienteId}")
    @Operation(summary = "Buscar planos do paciente", description = "Retorna todos os planos ativos do paciente (resultado em cache)")
    public ResponseEntity<List<PlanoResponse>> buscarPorPaciente(@PathVariable Long pacienteId) {
        logger.info("Buscando planos para paciente_id={}", pacienteId);
        List<PlanoResponse> planos = planoSaudeService.buscarPorPaciente(pacienteId)
                .stream()
                .map(p -> {
                    PlanoResponse r = PlanoResponse.from(p);
                    adicionarLinks(r);
                    return r;
                })
                .toList();
        return ResponseEntity.ok(planos);
    }

    @PostMapping("/gerar/{avaliacaoId}")
    @Operation(summary = "Gerar planos por avaliação", description = "Usa Spring AI com protocolos NASA para gerar planos de exercício e nutrição personalizados")
    public ResponseEntity<List<PlanoResponse>> gerarPlanos(@PathVariable Long avaliacaoId) {
        logger.info("Gerando planos para avaliacao_id={}", avaliacaoId);
        List<PlanoResponse> planos = planoSaudeService.gerarPlanos(avaliacaoId)
                .stream()
                .map(p -> {
                    PlanoResponse r = PlanoResponse.from(p);
                    adicionarLinks(r);
                    return r;
                })
                .toList();
        return ResponseEntity.ok(planos);
    }

    private void adicionarLinks(PlanoResponse response) {
        response.add(linkTo(methodOn(AvaliacaoController.class).buscar(response.getAvaliacaoId())).withRel("avaliacao"));
        response.add(linkTo(methodOn(PlanoSaudeController.class).gerarPlanos(response.getAvaliacaoId())).withRel("gerar-planos"));
    }
}
