package br.com.fiap.notification.repositories;

import br.com.fiap.notification.entities.Alerta;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AlertaRepository extends JpaRepository<Alerta, Long> {
    List<Alerta> findByPacienteIdOrderByDataCriacaoDesc(Long pacienteId);
}
