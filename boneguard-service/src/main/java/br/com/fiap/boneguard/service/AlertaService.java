package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.entities.Alerta;

import java.util.List;

public interface AlertaService {
    List<Alerta> buscarPorPaciente(Long pacienteId);
    Alerta marcarComoLido(Long id);
}
