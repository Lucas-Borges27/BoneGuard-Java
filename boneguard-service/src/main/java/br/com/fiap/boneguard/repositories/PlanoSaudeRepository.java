package br.com.fiap.boneguard.repositories;

import br.com.fiap.boneguard.entities.PlanoSaude;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface PlanoSaudeRepository extends JpaRepository<PlanoSaude, Long> {

    List<PlanoSaude> findByAvaliacaoId(Long avaliacaoId);

    @Query("SELECT p FROM PlanoSaude p WHERE p.avaliacao.paciente.id = :pacienteId AND p.ativo = true ORDER BY p.dataCriacao DESC")
    List<PlanoSaude> findAtivosByPacienteId(Long pacienteId);
}
