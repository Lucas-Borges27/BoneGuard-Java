package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.entities.Avaliacao;
import br.com.fiap.boneguard.enums.CategoriaPlano;
import br.com.fiap.boneguard.repositories.AvaliacaoRepository;
import br.com.fiap.boneguard.repositories.PacienteRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.support.ToolCallbacks;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
public class PlanoAIService {

    private static final Logger logger = LoggerFactory.getLogger(PlanoAIService.class);

    private static final String SYSTEM_PROMPT = """
            Você é um especialista em saúde óssea da missão BoneGuard.
            REGRAS ABSOLUTAS:
            1. Use as ferramentas APENAS para consulta interna — NUNCA copie ou repita os resultados delas na resposta.
            2. NÃO mencione nome, idade, sexo, peso, histórico familiar, histórico de avaliações, datas, scores nem dados pessoais.
            3. NÃO inclua seções, subtítulos (**texto**), texto introdutório longo, nem conclusões após os itens.
            FORMATO OBRIGATÓRIO — responda exatamente assim:
            Uma frase curta de contexto. (máx. 80 caracteres)
            * Recomendação objetiva, instrução prática de como aplicar
            * Recomendação objetiva, instrução prática de como aplicar
            (repetir de 4 a 6 vezes)
            Responda em português do Brasil.
            """;

    private final ChatClient chatClient;
    private final PacienteRepository pacienteRepository;
    private final AvaliacaoRepository avaliacaoRepository;

    @Autowired
    public PlanoAIService(@Lazy ChatClient.Builder builder,
                          PacienteRepository pacienteRepository,
                          AvaliacaoRepository avaliacaoRepository) {
        this.chatClient = builder.build();
        this.pacienteRepository = pacienteRepository;
        this.avaliacaoRepository = avaliacaoRepository;
    }

    // ─── Tools disponíveis para o modelo ─────────────────────────────────────

    @Tool(description = "Busca o perfil clínico completo do paciente dado seu ID: nome, idade, sexo, peso, nível de atividade, histórico familiar e dieta de cálcio")
    public String buscarPerfilPaciente(Long pacienteId) {
        return pacienteRepository.findById(pacienteId)
                .map(p -> "Perfil — Nome: %s | Idade: %d | Sexo: %s | Peso: %.1f kg | Atividade: %s | Histórico familiar: %s | Cálcio na dieta: %s"
                        .formatted(p.getNome(), p.getIdade(), p.getSexo(), p.getPeso(),
                                p.getNivelAtividade(),
                                Boolean.TRUE.equals(p.getHistoricoFamiliar()) ? "SIM" : "NÃO",
                                Boolean.TRUE.equals(p.getAlimentacaoCalcio()) ? "SIM" : "NÃO"))
                .orElse("Paciente não encontrado.");
    }

    @Tool(description = "Busca o histórico de avaliações de risco ósseo do paciente, retornando scores e classificações em ordem cronológica")
    public String buscarHistoricoAvaliacoes(Long pacienteId) {
        var avaliacoes = avaliacaoRepository.findByPacienteIdOrderByDataAvaliacaoDesc(pacienteId);
        if (avaliacoes.isEmpty()) return "Nenhuma avaliação registrada para este paciente.";
        return avaliacoes.stream()
                .map(a -> "Data: %s | Score: %.1f | Classificação: %s"
                        .formatted(a.getDataAvaliacao(), a.getScoreRisco(), a.getClassificacao()))
                .collect(Collectors.joining("\n"));
    }

    @Tool(description = "Retorna os protocolos NASA de preservação óssea para a categoria especificada: EXERCICIO ou NUTRICAO")
    public String buscarProtocoloNASA(String categoria) {
        if ("EXERCICIO".equalsIgnoreCase(categoria)) {
            return """
                    Protocolo NASA-ARED (Advanced Resistive Exercise Device):
                    - Exercícios de resistência gravitacional 2x/dia
                    - Treino aeróbico (CEVIS) 30min/dia com resistência
                    - Exercícios isométricos para carga óssea vertebral
                    - Caminhada com colete lastrado (70% do peso corporal)
                    - Treino de equilíbrio e propriocepção para prevenção de quedas
                    """;
        }
        return """
                Protocolo NASA de nutrição para preservação óssea:
                - Cálcio: 1.200–1.500mg/dia (alimentos + suplemento)
                - Vitamina D3: 2.000–4.000 UI/dia
                - Vitamina K2 (MK-7): 200mcg/dia para fixação de cálcio
                - Proteína: 1,2–1,5g/kg/dia para manutenção da massa óssea
                - Magnésio: 400mg/dia
                - Ômega-3: 2g/dia (ação anti-inflamatória)
                - Evitar: sódio >2g/dia, cafeína >400mg/dia, álcool
                """;
    }

    // ─── Geração do plano com Tooling ────────────────────────────────────────

    public String gerarDescricao(Avaliacao avaliacao, CategoriaPlano categoria) {
        String userPrompt = ("Consulte internamente o perfil e histórico do paciente ID=%d e o protocolo NASA de %s. " +
                "Score atual: %.1f, classificação: %s. " +
                "Gere SOMENTE as recomendações práticas de %s — sem repetir dados consultados.")
                .formatted(avaliacao.getPaciente().getId(), categoria.name(),
                        avaliacao.getScoreRisco(), avaliacao.getClassificacao(),
                        categoria.name().toLowerCase());

        logger.info("Gerando plano via Spring AI Tooling — avaliacao_id={} categoria={}", avaliacao.getId(), categoria);

        return chatClient.prompt()
                .system(SYSTEM_PROMPT)
                .user(userPrompt)
                .toolCallbacks(ToolCallbacks.from(this))
                .call()
                .content();
    }
}
