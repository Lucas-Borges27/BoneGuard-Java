package br.com.fiap.boneguard.controller;

import br.com.fiap.boneguard.dto.paciente.PacienteRequest;
import br.com.fiap.boneguard.dto.paciente.PacienteResponse;
import br.com.fiap.boneguard.entities.Paciente;
import br.com.fiap.boneguard.service.PacienteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.hateoas.Link;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/pacientes")
@Tag(name = "Pacientes", description = "Gerenciamento de pacientes monitorados")
@SecurityRequirement(name = "bearerAuth")
public class PacienteController {

    private static final Logger logger = LoggerFactory.getLogger(PacienteController.class);

    private final PacienteService pacienteService;

    public PacienteController(PacienteService pacienteService) {
        this.pacienteService = pacienteService;
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "[ADMIN] Listar todos os pacientes", description = "Retorna todos os pacientes cadastrados — acesso restrito ao administrador")
    public ResponseEntity<List<PacienteResponse>> listar() {
        List<PacienteResponse> lista = pacienteService.listarTodos().stream()
                .map(p -> {
                    PacienteResponse r = PacienteResponse.from(p);
                    adicionarLinks(r);
                    return r;
                })
                .toList();
        return ResponseEntity.ok(lista);
    }

    @PostMapping
    @Operation(summary = "Cadastrar paciente", description = "Cria um novo paciente no sistema")
    public ResponseEntity<PacienteResponse> criar(@Valid @RequestBody PacienteRequest request) {
        Paciente paciente = pacienteService.criar(request);
        logger.info("Paciente criado id={}", paciente.getId());
        PacienteResponse response = PacienteResponse.from(paciente);
        adicionarLinks(response);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}").buildAndExpand(paciente.getId()).toUri();
        return ResponseEntity.created(location).body(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Buscar paciente", description = "Retorna os dados de um paciente pelo id")
    public ResponseEntity<PacienteResponse> buscar(@PathVariable Long id) {
        Paciente paciente = pacienteService.buscarPorId(id);
        PacienteResponse response = PacienteResponse.from(paciente);
        adicionarLinks(response);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualizar paciente", description = "Atualiza os dados cadastrais de um paciente")
    public ResponseEntity<PacienteResponse> atualizar(@PathVariable Long id,
                                                       @Valid @RequestBody PacienteRequest request) {
        Paciente paciente = pacienteService.atualizar(id, request);
        logger.info("Paciente atualizado id={}", id);
        PacienteResponse response = PacienteResponse.from(paciente);
        adicionarLinks(response);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "[ADMIN] Remover paciente", description = "Remove um paciente pelo id — acesso restrito ao administrador")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        pacienteService.deletar(id);
        logger.info("Paciente removido id={}", id);
        return ResponseEntity.noContent().build();
    }

    private void adicionarLinks(PacienteResponse response) {
        response.add(linkTo(methodOn(PacienteController.class).buscar(response.getId())).withSelfRel());
        response.add(linkTo(methodOn(AvaliacaoController.class).buscarPorPaciente(response.getId())).withRel("avaliacoes"));
        response.add(linkTo(methodOn(EvolucaoController.class).buscarPorPaciente(response.getId())).withRel("evolucao"));
        response.add(linkTo(methodOn(AlertaController.class).buscarPorPaciente(response.getId())).withRel("alertas"));
        response.add(Link.of("/planos/paciente/" + response.getId()).withRel("planos"));
    }
}
