package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.paciente.PacienteRequest;
import br.com.fiap.boneguard.entities.Paciente;
import br.com.fiap.boneguard.exception.ResourceNotFoundException;
import br.com.fiap.boneguard.repositories.PacienteRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
class PacienteServiceImpl implements PacienteService {

    private final PacienteRepository pacienteRepository;

    public PacienteServiceImpl(PacienteRepository pacienteRepository) {
        this.pacienteRepository = pacienteRepository;
    }

    @Override
    public Paciente criar(PacienteRequest request) {
        Paciente paciente = new Paciente();
        preencherDados(paciente, request);
        paciente.setDataCadastro(LocalDate.now());
        return pacienteRepository.save(paciente);
    }

    @Override
    public Paciente buscarPorId(Long id) {
        return pacienteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente", id));
    }

    @Override
    public Paciente atualizar(Long id, PacienteRequest request) {
        Paciente paciente = buscarPorId(id);
        preencherDados(paciente, request);
        return pacienteRepository.save(paciente);
    }

    @Override
    public List<Paciente> listarTodos() {
        return pacienteRepository.findAll();
    }

    @Override
    public void deletar(Long id) {
        if (!pacienteRepository.existsById(id)) {
            throw new ResourceNotFoundException("Paciente", id);
        }
        pacienteRepository.deleteById(id);
    }

    private void preencherDados(Paciente paciente, PacienteRequest request) {
        paciente.setNome(request.nome());
        paciente.setIdade(request.idade());
        paciente.setSexo(request.sexo());
        paciente.setPeso(request.peso());
        paciente.setHistoricoFamiliar(request.historicoFamiliar());
        paciente.setNivelAtividade(request.nivelAtividade());
        paciente.setAlimentacaoCalcio(request.alimentacaoCalcio());
    }
}
