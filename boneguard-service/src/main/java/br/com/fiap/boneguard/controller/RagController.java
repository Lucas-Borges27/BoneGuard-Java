package br.com.fiap.boneguard.controller;

import br.com.fiap.boneguard.service.NasaRagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/rag")
@Validated
@Tag(name = "RAG — Consulta Inteligente", description = "Retrieval-Augmented Generation sobre protocolos NASA de saúde óssea")
@SecurityRequirement(name = "bearerAuth")
public class RagController {

    private static final Logger logger = LoggerFactory.getLogger(RagController.class);

    private final NasaRagService nasaRagService;

    public RagController(NasaRagService nasaRagService) {
        this.nasaRagService = nasaRagService;
    }

    @GetMapping("/consultar")
    @Operation(
        summary = "Consultar base de conhecimento NASA",
        description = """
            Realiza RAG (Retrieval-Augmented Generation) sobre a base de protocolos NASA de saúde óssea.
            O sistema recupera documentos relevantes à pergunta e os usa como contexto para gerar
            uma resposta fundamentada via LLM. Exemplos de perguntas:
            - "Qual a dose recomendada de cálcio?"
            - "Que exercícios NASA recomendam para osteoporose?"
            - "O que é o protocolo ARED?"
            - "Como interpretar o score de risco ósseo?"
            """
    )
    public ResponseEntity<RagResponse> consultar(
            @RequestParam @NotBlank @Size(max = 300) String pergunta) {
        logger.info("RAG consulta recebida: '{}'", pergunta);
        String resposta = nasaRagService.consultar(pergunta);
        return ResponseEntity.ok(new RagResponse(pergunta, resposta));
    }

    public record RagResponse(String pergunta, String resposta) {}
}
