package br.com.fiap.boneguard.repositories;

import br.com.fiap.boneguard.entities.Radiografia;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RadiografiaRepository extends JpaRepository<Radiografia, Long> {
    List<Radiografia> findByAvaliacaoId(Long avaliacaoId);
}
