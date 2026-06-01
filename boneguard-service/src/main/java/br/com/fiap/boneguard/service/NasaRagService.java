package br.com.fiap.boneguard.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.document.Document;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * RAG (Retrieval-Augmented Generation) com protocolos NASA de saúde óssea.
 *
 * Fluxo:
 *  1. Retrieval  — busca documentos relevantes da base de conhecimento NASA por palavras-chave
 *  2. Augmented  — injeta os documentos recuperados como contexto no prompt
 *  3. Generation — ChatClient gera resposta fundamentada no contexto recuperado
 */
@Service
public class NasaRagService {

    private static final Logger logger = LoggerFactory.getLogger(NasaRagService.class);

    private final ChatClient chatClient;
    private final List<Document> knowledgeBase;

    public NasaRagService(ChatClient.Builder builder) {
        this.chatClient = builder.build();
        this.knowledgeBase = carregarBaseConhecimento();
    }

    // ─── 1. RETRIEVAL ────────────────────────────────────────────────────────

    private List<Document> recuperar(String pergunta) {
        String query = pergunta.toLowerCase();
        return knowledgeBase.stream()
                .filter(doc -> {
                    String texto = doc.getFormattedContent().toLowerCase();
                    return query.contains("exerc") && texto.contains("exerc")
                        || query.contains("nutri") && texto.contains("nutri")
                        || query.contains("cálcio") && texto.contains("cálcio")
                        || query.contains("calcio") && texto.contains("cálcio")
                        || query.contains("vitamina") && texto.contains("vitamina")
                        || query.contains("osteoporos") && texto.contains("osteoporos")
                        || query.contains("risco") && texto.contains("risco")
                        || query.contains("score") && texto.contains("score")
                        || query.contains("nasa") && texto.contains("nasa")
                        || query.contains("gravidade") && texto.contains("gravidade")
                        || query.contains("ared") && texto.contains("ared")
                        || query.contains("cevis") && texto.contains("cevis");
                })
                .limit(3)
                .toList();
    }

    // ─── 2. AUGMENTED + 3. GENERATION ────────────────────────────────────────

    public String consultar(String pergunta) {
        List<Document> documentosRecuperados = recuperar(pergunta);

        // Se nenhum documento específico foi recuperado, usa todos (contexto geral)
        List<Document> contexto = documentosRecuperados.isEmpty() ? knowledgeBase : documentosRecuperados;

        String contextFormatado = contexto.stream()
                .map(Document::getFormattedContent)
                .collect(Collectors.joining("\n\n---\n\n"));

        logger.info("RAG — recuperados {} documentos para a pergunta: '{}'",
                contexto.size(), pergunta.length() > 60 ? pergunta.substring(0, 60) + "..." : pergunta);

        String systemPrompt = """
                Você é o assistente especializado BoneGuard, focado em saúde óssea e prevenção de osteoporose.
                Use APENAS as informações do contexto abaixo para responder.
                Se a informação não estiver no contexto, diga que não encontrou dados suficientes.
                Responda em português do Brasil, de forma clara e objetiva. Máximo 400 caracteres.

                CONTEXTO RECUPERADO:
                """ + contextFormatado;

        return chatClient.prompt()
                .system(systemPrompt)
                .user(pergunta)
                .call()
                .content();
    }

    // ─── BASE DE CONHECIMENTO NASA ────────────────────────────────────────────

    private List<Document> carregarBaseConhecimento() {
        return List.of(
            new Document("""
                Protocolo NASA-ARED de Exercícios para Preservação Óssea:
                O Advanced Resistive Exercise Device (ARED) foi desenvolvido pela NASA para combater
                a perda óssea em microgravidade. Recomendações adaptadas para pacientes terrestres:
                - Exercícios de resistência gravitacional 2x por dia (agachamento, leg press, deadlift)
                - Treino aeróbico via CEVIS (Cycle Ergometer with Vibration Isolation) 30 min/dia
                - Exercícios isométricos para carga óssea vertebral
                - Caminhada com colete lastrado equivalente a 70% do peso corporal
                - Treino de equilíbrio e propriocepção 3x por semana para prevenção de quedas
                Astronautas realizam 2,5 horas de exercícios por dia para manter densidade óssea.
                """),

            new Document("""
                Protocolo NASA de Nutrição para Saúde Óssea:
                A NASA definiu diretrizes nutricionais específicas para manutenção óssea:
                - Cálcio: 1.200 a 1.500 mg por dia (combinando alimentos + suplemento)
                - Vitamina D3: 2.000 a 4.000 UI por dia para absorção de cálcio
                - Vitamina K2 (MK-7): 200 mcg por dia para fixação do cálcio nos ossos
                - Proteína: 1,2 a 1,5 g por kg de peso por dia para manutenção da massa óssea
                - Magnésio: 400 mg por dia (cofator essencial para metabolismo ósseo)
                - Ômega-3: 2 g por dia para ação anti-inflamatória e proteção óssea
                - Evitar: sódio acima de 2 g/dia, cafeína acima de 400 mg/dia, álcool excessivo
                """),

            new Document("""
                Classificação de Risco Ósseo BoneGuard — baseada em escores:
                O sistema BoneGuard utiliza um score de risco de 0 a 100 para classificar pacientes:
                - Score 0 a 30 (BAIXO risco): monitoramento semestral, manutenção de hábitos saudáveis
                - Score 31 a 60 (MODERADO risco): acompanhamento trimestral, início de suplementação
                - Score 61 a 79 (ALTO risco): consulta médica em até 30 dias, densitometria óssea urgente
                - Score 80 a 100 (CRÍTICO risco): encaminhamento imediato ao reumatologista ou ortopedista
                Fatores que aumentam o score: histórico familiar, sedentarismo, baixo consumo de cálcio,
                sexo feminino após menopausa, baixo peso corporal, uso de corticosteroides.
                """),

            new Document("""
                Osteoporose e Microgravidade — Conexão NASA-BoneGuard:
                A osteoporose e a perda óssea em microgravidade compartilham mecanismos semelhantes:
                ambas resultam de desequilíbrio entre reabsorção e formação óssea.
                Astronautas perdem de 1 a 2% da massa óssea por mês em microgravidade,
                equivalente ao que pacientes com osteoporose perdem em um ano na Terra.
                Os protocolos NASA, originalmente criados para missões Artemis e ISS,
                foram adaptados pelo BoneGuard para pacientes terrestres em risco.
                O sistema monitora evolução óssea, alerta riscos e gera planos personalizados
                baseados nos mesmos princípios científicos usados para proteger astronautas.
                """),

            new Document("""
                Densidade Mineral Óssea e Exames de Monitoramento:
                Exames recomendados para monitoramento da saúde óssea:
                - Densitometria óssea (DXA): padrão-ouro para diagnóstico de osteoporose
                  T-score acima de -1,0: normal | entre -1,0 e -2,5: osteopenia | abaixo de -2,5: osteoporose
                - Exames laboratoriais: cálcio sérico, fósforo, vitamina D (25-OH), PTH, marcadores ósseos
                - Radiografia digital: detecta fraturas vertebrais por compressão
                - Análise de composição corporal: avaliação de massa magra e gordura visceral
                Monitoramento recomendado pela NASA para missões longas e pelo BoneGuard para alto risco:
                densitometria semestral, exames laboratoriais trimestrais.
                """)
        );
    }
}
