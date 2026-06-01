package br.com.fiap.boneguard.configs;

import br.com.fiap.boneguard.service.PlanoAIService;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.ai.tool.method.MethodToolCallbackProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Registra as tools do BoneGuard como ferramentas MCP (Model Context Protocol).
 *
 * As tools expostas via MCP podem ser utilizadas por qualquer cliente MCP externo
 * (ex: Claude Desktop, Cursor, outros agentes de IA) para consultar dados do BoneGuard.
 *
 * Tools registradas:
 *  - buscarPerfilPaciente     — retorna dados clínicos do paciente
 *  - buscarHistoricoAvaliacoes — retorna histórico de scores de risco ósseo
 *  - buscarProtocoloNASA      — retorna protocolo NASA para exercício ou nutrição
 */
@Configuration
public class McpToolsConfig {

    @Bean
    public ToolCallbackProvider boneguardMcpTools(PlanoAIService planoAIService) {
        return MethodToolCallbackProvider.builder()
                .toolObjects(planoAIService)
                .build();
    }
}
