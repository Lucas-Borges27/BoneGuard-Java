package br.com.fiap.boneguard.configs;

import br.com.fiap.boneguard.service.PlanoAIService;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.ai.tool.method.MethodToolCallbackProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;

@Configuration
public class McpToolsConfig {

    @Bean
    public ToolCallbackProvider boneguardMcpTools(@Lazy PlanoAIService planoAIService) {
        return MethodToolCallbackProvider.builder()
                .toolObjects(planoAIService)
                .build();
    }
}
