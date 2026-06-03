package br.com.fiap.boneguard.repositories;

import br.com.fiap.boneguard.entities.Avaliacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AvaliacaoRepository extends JpaRepository<Avaliacao, Long> {

    @Query("SELECT a FROM Avaliacao a JOIN FETCH a.paciente WHERE a.id = :id")
    Optional<Avaliacao> findByIdWithPaciente(@Param("id") Long id);

    @Query("SELECT a FROM Avaliacao a JOIN FETCH a.paciente WHERE a.paciente.id = :pacienteId ORDER BY a.dataAvaliacao DESC, a.id DESC")
    List<Avaliacao> findByPacienteIdOrderByDataAvaliacaoDesc(@Param("pacienteId") Long pacienteId);
}
