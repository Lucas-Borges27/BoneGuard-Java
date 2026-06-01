package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.avaliacao.AvaliacaoRequest;
import br.com.fiap.boneguard.entities.Avaliacao;

import java.util.List;

public interface AvaliacaoService {
    Avaliacao criar(AvaliacaoRequest request);
    Avaliacao buscarPorId(Long id);
    List<Avaliacao> buscarHistoricoPorPaciente(Long pacienteId);
}
