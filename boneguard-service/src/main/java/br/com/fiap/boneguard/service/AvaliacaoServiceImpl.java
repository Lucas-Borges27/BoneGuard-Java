package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.avaliacao.AvaliacaoRequest;
import br.com.fiap.boneguard.entities.Avaliacao;
import br.com.fiap.boneguard.entities.Paciente;
import br.com.fiap.boneguard.enums.Classificacao;
import br.com.fiap.boneguard.exception.ResourceNotFoundException;
import br.com.fiap.boneguard.exception.ValidationException;
import br.com.fiap.boneguard.external_interface.rabbitmq.AlertaEvent;
import br.com.fiap.boneguard.external_interface.rabbitmq.AlertaPublisher;
import br.com.fiap.boneguard.repositories.AvaliacaoRepository;
import br.com.fiap.boneguard.repositories.PacienteRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
class AvaliacaoServiceImpl implements AvaliacaoService {

    private static final Logger logger = LoggerFactory.getLogger(AvaliacaoServiceImpl.class);

    private final AvaliacaoRepository avaliacaoRepository;
    private final PacienteRepository pacienteRepository;
    private final AlertaPublisher alertaPublisher;

    public AvaliacaoServiceImpl(AvaliacaoRepository avaliacaoRepository,
                                PacienteRepository pacienteRepository,
                                AlertaPublisher alertaPublisher) {
        this.avaliacaoRepository = avaliacaoRepository;
        this.pacienteRepository = pacienteRepository;
        this.alertaPublisher = alertaPublisher;
    }

    @Override
    @Transactional
    public Avaliacao criar(AvaliacaoRequest request) {
        if (request.scoreRisco() < 0 || request.scoreRisco() > 100) {
            throw new ValidationException("Score deve estar entre 0 e 100. Recebido: " + request.scoreRisco());
        }

        Paciente paciente = pacienteRepository.findById(request.pacienteId())
                .orElseThrow(() -> new ResourceNotFoundException("Paciente", request.pacienteId()));

        Classificacao classificacao = Classificacao.fromScore(request.scoreRisco());

        Avaliacao avaliacao = new Avaliacao();
        avaliacao.setPaciente(paciente);
        avaliacao.setScoreRisco(request.scoreRisco());
        avaliacao.setClassificacao(classificacao);
        avaliacao.setDataAvaliacao(LocalDate.now());
        avaliacao.setPlanoGerado(false);

        Avaliacao salva = avaliacaoRepository.save(avaliacao);
        logger.info("Avaliação criada id={} paciente={} classificacao={}", salva.getId(), paciente.getId(), classificacao);

        if (classificacao == Classificacao.ALTO) {
            AlertaEvent event = new AlertaEvent(
                    paciente.getId(),
                    paciente.getNome(),
                    salva.getId(),
                    request.scoreRisco(),
                    classificacao.name(),
                    "ALERTA ALTO RISCO: " + paciente.getNome() + " apresenta score " + request.scoreRisco() + ". Consulta médica urgente recomendada.",
                    LocalDate.now()
            );
            alertaPublisher.publicar(event);
        }

        return salva;
    }

    @Override
    public Avaliacao buscarPorId(Long id) {
        return avaliacaoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Avaliação", id));
    }

    @Override
    public List<Avaliacao> buscarHistoricoPorPaciente(Long pacienteId) {
        if (!pacienteRepository.existsById(pacienteId)) {
            throw new ResourceNotFoundException("Paciente", pacienteId);
        }
        return avaliacaoRepository.findByPacienteIdOrderByDataAvaliacaoDesc(pacienteId);
    }
}
