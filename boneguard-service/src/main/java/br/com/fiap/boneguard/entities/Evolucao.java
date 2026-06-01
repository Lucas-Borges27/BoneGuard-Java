package br.com.fiap.boneguard.entities;

import br.com.fiap.boneguard.enums.NivelAtividade;
import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "TB_EVOLUCAO_BONEGUARD")
public class Evolucao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "paciente_id", nullable = false)
    private Paciente paciente;

    @Column(name = "peso_atual", nullable = false)
    private Double pesoAtual;

    @Enumerated(EnumType.STRING)
    @Column(name = "nivel_atividade_atual", nullable = false, length = 20)
    private NivelAtividade nivelAtividadeAtual;

    @Column(name = "observacoes", length = 1000)
    private String observacoes;

    @Column(name = "data_registro", nullable = false)
    private LocalDate dataRegistro;

    public Evolucao() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Paciente getPaciente() { return paciente; }
    public void setPaciente(Paciente paciente) { this.paciente = paciente; }

    public Double getPesoAtual() { return pesoAtual; }
    public void setPesoAtual(Double pesoAtual) { this.pesoAtual = pesoAtual; }

    public NivelAtividade getNivelAtividadeAtual() { return nivelAtividadeAtual; }
    public void setNivelAtividadeAtual(NivelAtividade nivelAtividadeAtual) { this.nivelAtividadeAtual = nivelAtividadeAtual; }

    public String getObservacoes() { return observacoes; }
    public void setObservacoes(String observacoes) { this.observacoes = observacoes; }

    public LocalDate getDataRegistro() { return dataRegistro; }
    public void setDataRegistro(LocalDate dataRegistro) { this.dataRegistro = dataRegistro; }
}
