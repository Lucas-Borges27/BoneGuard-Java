package br.com.fiap.boneguard.repositories;

import br.com.fiap.boneguard.entities.Evolucao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EvolucaoRepository extends JpaRepository<Evolucao, Long> {
    List<Evolucao> findByPacienteIdOrderByDataRegistroDesc(Long pacienteId);
}
