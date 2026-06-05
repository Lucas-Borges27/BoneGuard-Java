package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.evolucao.EvolucaoRequest;
import br.com.fiap.boneguard.entities.Evolucao;
import br.com.fiap.boneguard.entities.Paciente;
import br.com.fiap.boneguard.exception.ResourceNotFoundException;
import br.com.fiap.boneguard.repositories.EvolucaoRepository;
import br.com.fiap.boneguard.repositories.PacienteRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class EvolucaoServiceImpl implements EvolucaoService {

    private final EvolucaoRepository evolucaoRepository;
    private final PacienteRepository pacienteRepository;

    public EvolucaoServiceImpl(EvolucaoRepository evolucaoRepository, PacienteRepository pacienteRepository) {
        this.evolucaoRepository = evolucaoRepository;
        this.pacienteRepository = pacienteRepository;
    }

    @Override
    public List<Evolucao> buscarPorPaciente(Long pacienteId) {
        if (!pacienteRepository.existsById(pacienteId)) {
            throw new ResourceNotFoundException("Paciente", pacienteId);
        }
        return evolucaoRepository.findByPacienteIdOrderByDataRegistroDesc(pacienteId);
    }

    @Override
    public Evolucao registrar(EvolucaoRequest request) {
        Paciente paciente = pacienteRepository.findById(request.pacienteId())
                .orElseThrow(() -> new ResourceNotFoundException("Paciente", request.pacienteId()));

        Evolucao evolucao = new Evolucao();
        evolucao.setPaciente(paciente);
        evolucao.setPesoAtual(request.pesoAtual());
        evolucao.setNivelAtividadeAtual(request.nivelAtividadeAtual());
        evolucao.setObservacoes(request.observacoes());
        evolucao.setDataRegistro(LocalDate.now());

        return evolucaoRepository.save(evolucao);
    }
}
