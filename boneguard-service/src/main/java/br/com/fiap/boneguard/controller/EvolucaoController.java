package br.com.fiap.boneguard.controller;

import br.com.fiap.boneguard.dto.evolucao.EvolucaoRequest;
import br.com.fiap.boneguard.dto.evolucao.EvolucaoResponse;
import br.com.fiap.boneguard.service.EvolucaoService;
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
@RequestMapping("/evolucao")
@Tag(name = "Evolução", description = "Histórico de evolução clínica dos pacientes")
@SecurityRequirement(name = "bearerAuth")
public class EvolucaoController {

    private static final Logger logger = LoggerFactory.getLogger(EvolucaoController.class);

    private final EvolucaoService evolucaoService;

    public EvolucaoController(EvolucaoService evolucaoService) {
        this.evolucaoService = evolucaoService;
    }

    @GetMapping("/{pacienteId}")
    @Operation(summary = "Listar evolução do paciente", description = "Retorna o histórico de evolução clínica de um paciente")
    public ResponseEntity<List<EvolucaoResponse>> buscarPorPaciente(@PathVariable Long pacienteId) {
        List<EvolucaoResponse> evolucoes = evolucaoService.buscarPorPaciente(pacienteId)
                .stream()
                .map(e -> {
                    EvolucaoResponse r = EvolucaoResponse.from(e);
                    adicionarLinks(r);
                    return r;
                })
                .toList();
        return ResponseEntity.ok(evolucoes);
    }

    @PostMapping
    @Operation(summary = "Registrar evolução", description = "Registra um novo snapshot de evolução clínica do paciente")
    public ResponseEntity<EvolucaoResponse> registrar(@Valid @RequestBody EvolucaoRequest request) {
        logger.info("Registrando evolução para paciente_id={}", request.pacienteId());
        var evolucao = evolucaoService.registrar(request);
        EvolucaoResponse response = EvolucaoResponse.from(evolucao);
        adicionarLinks(response);
        URI location = ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/evolucao/{pacienteId}").buildAndExpand(request.pacienteId()).toUri();
        return ResponseEntity.created(location).body(response);
    }

    private void adicionarLinks(EvolucaoResponse response) {
        response.add(linkTo(methodOn(EvolucaoController.class).buscarPorPaciente(response.getPacienteId())).withSelfRel());
        response.add(linkTo(methodOn(PacienteController.class).buscar(response.getPacienteId())).withRel("paciente"));
        response.add(linkTo(methodOn(AvaliacaoController.class).buscarPorPaciente(response.getPacienteId())).withRel("avaliacoes"));
    }
}
