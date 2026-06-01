package br.com.fiap.boneguard.repositories;

import br.com.fiap.boneguard.entities.Avaliacao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AvaliacaoRepository extends JpaRepository<Avaliacao, Long> {
    List<Avaliacao> findByPacienteIdOrderByDataAvaliacaoDesc(Long pacienteId);
}
