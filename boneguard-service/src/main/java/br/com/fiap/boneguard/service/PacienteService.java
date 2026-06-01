package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.paciente.PacienteRequest;
import br.com.fiap.boneguard.entities.Paciente;

import java.util.List;

public interface PacienteService {
    Paciente criar(PacienteRequest request);
    Paciente buscarPorId(Long id);
    Paciente atualizar(Long id, PacienteRequest request);
    List<Paciente> listarTodos();
    void deletar(Long id);
}
