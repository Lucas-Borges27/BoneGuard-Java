package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.entities.PlanoSaude;

import java.util.List;

public interface PlanoSaudeService {
    List<PlanoSaude> buscarPorPaciente(Long pacienteId);
    List<PlanoSaude> gerarPlanos(Long avaliacaoId);
}
