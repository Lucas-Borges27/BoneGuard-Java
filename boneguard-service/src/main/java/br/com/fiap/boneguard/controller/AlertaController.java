package br.com.fiap.boneguard.controller;

import br.com.fiap.boneguard.dto.alerta.AlertaResponse;
import br.com.fiap.boneguard.service.AlertaService;
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
@RequestMapping("/alertas")
@Tag(name = "Alertas", description = "Alertas de risco gerados automaticamente pelo sistema")
@SecurityRequirement(name = "bearerAuth")
public class AlertaController {

    private static final Logger logger = LoggerFactory.getLogger(AlertaController.class);

    private final AlertaService alertaService;

    public AlertaController(AlertaService alertaService) {
        this.alertaService = alertaService;
    }

    @GetMapping("/paciente/{pacienteId}")
    @Operation(summary = "Listar alertas do paciente", description = "Retorna todos os alertas de um paciente, do mais recente ao mais antigo")
    public ResponseEntity<List<AlertaResponse>> buscarPorPaciente(@PathVariable Long pacienteId) {
        List<AlertaResponse> alertas = alertaService.buscarPorPaciente(pacienteId)
                .stream()
                .map(a -> {
                    AlertaResponse r = AlertaResponse.from(a);
                    adicionarLinks(r);
                    return r;
                })
                .toList();
        return ResponseEntity.ok(alertas);
    }

    @PatchMapping("/{id}/lido")
    @Operation(summary = "Marcar alerta como lido", description = "Atualiza o status do alerta para LIDO")
    public ResponseEntity<AlertaResponse> marcarComoLido(@PathVariable Long id) {
        logger.info("Marcando alerta id={} como lido", id);
        AlertaResponse response = AlertaResponse.from(alertaService.marcarComoLido(id));
        adicionarLinks(response);
        return ResponseEntity.ok(response);
    }

    private void adicionarLinks(AlertaResponse response) {
        response.add(linkTo(methodOn(AlertaController.class).buscarPorPaciente(response.getPacienteId())).withSelfRel());
        response.add(linkTo(methodOn(AlertaController.class).marcarComoLido(response.getId())).withRel("marcar-lido"));
        response.add(linkTo(methodOn(PacienteController.class).buscar(response.getPacienteId())).withRel("paciente"));
        response.add(linkTo(methodOn(AvaliacaoController.class).buscar(response.getAvaliacaoId())).withRel("avaliacao"));
    }
}
