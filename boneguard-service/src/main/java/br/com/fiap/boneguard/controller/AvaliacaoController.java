package br.com.fiap.boneguard.controller;

import br.com.fiap.boneguard.dto.avaliacao.AvaliacaoRequest;
import br.com.fiap.boneguard.dto.avaliacao.AvaliacaoResponse;
import br.com.fiap.boneguard.dto.avaliacao.HistoricoAvaliacaoResponse;
import br.com.fiap.boneguard.entities.Avaliacao;
import br.com.fiap.boneguard.service.AvaliacaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/avaliacoes")
@Tag(name = "Avaliações", description = "Avaliações de risco ósseo dos pacientes")
@SecurityRequirement(name = "bearerAuth")
public class AvaliacaoController {

    private static final Logger logger = LoggerFactory.getLogger(AvaliacaoController.class);

    private final AvaliacaoService avaliacaoService;

    public AvaliacaoController(AvaliacaoService avaliacaoService) {
        this.avaliacaoService = avaliacaoService;
    }

    @PostMapping
    @Operation(summary = "Criar avaliação", description = "Registra nova avaliação de risco ósseo e publica alerta se classificação for ALTO")
    public ResponseEntity<AvaliacaoResponse> criar(@Valid @RequestBody AvaliacaoRequest request) {
        Avaliacao avaliacao = avaliacaoService.criar(request);
        logger.info("Avaliação criada id={}", avaliacao.getId());
        AvaliacaoResponse response = AvaliacaoResponse.from(avaliacao);
        adicionarLinks(response);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}").buildAndExpand(avaliacao.getId()).toUri();
        return ResponseEntity.created(location).body(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Buscar avaliação por id", description = "Retorna uma avaliação específica")
    public ResponseEntity<AvaliacaoResponse> buscar(@PathVariable Long id) {
        Avaliacao avaliacao = avaliacaoService.buscarPorId(id);
        AvaliacaoResponse response = AvaliacaoResponse.from(avaliacao);
        adicionarLinks(response);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/paciente/{pacienteId}")
    @Operation(summary = "Histórico de avaliações do paciente",
               description = "Retorna todas as avaliações com tendência calculada (MELHORA/PIORA/ESTAVEL/SEM_HISTORICO) pelo delta entre o primeiro e o último score")
    public ResponseEntity<HistoricoAvaliacaoResponse> buscarPorPaciente(@PathVariable Long pacienteId) {
        List<Avaliacao> avaliacoes = avaliacaoService.buscarHistoricoPorPaciente(pacienteId);
        return ResponseEntity.ok(HistoricoAvaliacaoResponse.from(pacienteId, avaliacoes));
    }

    private void adicionarLinks(AvaliacaoResponse response) {
        response.add(linkTo(methodOn(AvaliacaoController.class).buscar(response.getId())).withSelfRel());
        response.add(linkTo(methodOn(PacienteController.class).buscar(response.getPacienteId())).withRel("paciente"));
        response.add(linkTo(methodOn(PlanoSaudeController.class).gerarPlanos(response.getId())).withRel("gerar-planos"));
    }
}
