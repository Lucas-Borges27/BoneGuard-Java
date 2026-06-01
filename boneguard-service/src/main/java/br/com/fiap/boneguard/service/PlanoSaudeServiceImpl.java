package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.entities.Avaliacao;
import br.com.fiap.boneguard.entities.PlanoSaude;
import br.com.fiap.boneguard.enums.CategoriaPlano;
import br.com.fiap.boneguard.exception.ResourceNotFoundException;
import br.com.fiap.boneguard.exception.ValidationException;
import br.com.fiap.boneguard.repositories.AvaliacaoRepository;
import br.com.fiap.boneguard.repositories.PlanoSaudeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
class PlanoSaudeServiceImpl implements PlanoSaudeService {

    private static final Logger logger = LoggerFactory.getLogger(PlanoSaudeServiceImpl.class);

    private final PlanoSaudeRepository planoSaudeRepository;
    private final AvaliacaoRepository avaliacaoRepository;
    private final PlanoAIService planoAIService;

    public PlanoSaudeServiceImpl(PlanoSaudeRepository planoSaudeRepository,
                                 AvaliacaoRepository avaliacaoRepository,
                                 PlanoAIService planoAIService) {
        this.planoSaudeRepository = planoSaudeRepository;
        this.avaliacaoRepository = avaliacaoRepository;
        this.planoAIService = planoAIService;
    }

    @Override
    @Cacheable(value = "planos-paciente", key = "#pacienteId")
    public List<PlanoSaude> buscarPorPaciente(Long pacienteId) {
        logger.info("Buscando planos ativos para paciente_id={}", pacienteId);
        return planoSaudeRepository.findAtivosByPacienteId(pacienteId);
    }

    @Override
    @Transactional
    @CacheEvict(value = "planos-paciente", allEntries = true)
    public List<PlanoSaude> gerarPlanos(Long avaliacaoId) {
        Avaliacao avaliacao = avaliacaoRepository.findById(avaliacaoId)
                .orElseThrow(() -> new ResourceNotFoundException("Avaliação", avaliacaoId));

        if (avaliacao.getPlanoGerado()) {
            throw new ValidationException("Planos já foram gerados para a avaliação id: " + avaliacaoId);
        }

        PlanoSaude planoExercicio = criarPlano(avaliacao, CategoriaPlano.EXERCICIO);
        PlanoSaude planoNutricao = criarPlano(avaliacao, CategoriaPlano.NUTRICAO);

        List<PlanoSaude> planos = planoSaudeRepository.saveAll(List.of(planoExercicio, planoNutricao));

        avaliacao.setPlanoGerado(true);
        avaliacaoRepository.save(avaliacao);

        logger.info("Planos gerados para avaliacao_id={}: exercicio_id={} nutricao_id={}",
                avaliacaoId, planos.get(0).getId(), planos.get(1).getId());

        return planos;
    }

    private PlanoSaude criarPlano(Avaliacao avaliacao, CategoriaPlano categoria) {
        String descricao = planoAIService.gerarDescricao(avaliacao, categoria);
        PlanoSaude plano = new PlanoSaude();
        plano.setAvaliacao(avaliacao);
        plano.setCategoria(categoria);
        plano.setDescricao(descricao);
        plano.setAtivo(true);
        plano.setDataCriacao(LocalDate.now());
        return plano;
    }
}
