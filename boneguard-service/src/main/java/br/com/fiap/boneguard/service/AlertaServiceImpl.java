package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.entities.Alerta;
import br.com.fiap.boneguard.enums.StatusAlerta;
import br.com.fiap.boneguard.exception.ResourceNotFoundException;
import br.com.fiap.boneguard.repositories.AlertaRepository;
import br.com.fiap.boneguard.repositories.PacienteRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AlertaServiceImpl implements AlertaService {

    private static final Logger logger = LoggerFactory.getLogger(AlertaServiceImpl.class);

    private final AlertaRepository alertaRepository;
    private final PacienteRepository pacienteRepository;

    public AlertaServiceImpl(AlertaRepository alertaRepository, PacienteRepository pacienteRepository) {
        this.alertaRepository = alertaRepository;
        this.pacienteRepository = pacienteRepository;
    }

    @Override
    public List<Alerta> buscarPorPaciente(Long pacienteId) {
        if (!pacienteRepository.existsById(pacienteId)) {
            throw new ResourceNotFoundException("Paciente", pacienteId);
        }
        return alertaRepository.findByPacienteIdOrderByDataCriacaoDesc(pacienteId);
    }

    @Override
    @Transactional
    public Alerta marcarComoLido(Long id) {
        Alerta alerta = alertaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Alerta", id));
        alerta.setStatus(StatusAlerta.LIDO);
        logger.info("Alerta id={} marcado como LIDO", id);
        return alertaRepository.save(alerta);
    }
}
