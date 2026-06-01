package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.evolucao.EvolucaoRequest;
import br.com.fiap.boneguard.entities.Evolucao;

import java.util.List;

public interface EvolucaoService {
    List<Evolucao> buscarPorPaciente(Long pacienteId);
    Evolucao registrar(EvolucaoRequest request);
}
