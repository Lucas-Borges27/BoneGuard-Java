package br.com.fiap.boneguard.entities;

import br.com.fiap.boneguard.entities.converter.BooleanSnConverter;
import br.com.fiap.boneguard.enums.Classificacao;
import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "TB_AVALIACAO_BONEGUARD")
public class Avaliacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "paciente_id", nullable = false)
    private Paciente paciente;

    @Column(name = "score_risco", nullable = false)
    private Double scoreRisco;

    @Enumerated(EnumType.STRING)
    @Column(name = "classificacao", nullable = false, length = 10)
    private Classificacao classificacao;

    @Column(name = "data_avaliacao", nullable = false)
    private LocalDate dataAvaliacao;

    @Convert(converter = BooleanSnConverter.class)
    @Column(name = "plano_gerado", nullable = false, length = 1)
    private Boolean planoGerado;

    public Avaliacao() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Paciente getPaciente() { return paciente; }
    public void setPaciente(Paciente paciente) { this.paciente = paciente; }

    public Double getScoreRisco() { return scoreRisco; }
    public void setScoreRisco(Double scoreRisco) { this.scoreRisco = scoreRisco; }

    public Classificacao getClassificacao() { return classificacao; }
    public void setClassificacao(Classificacao classificacao) { this.classificacao = classificacao; }

    public LocalDate getDataAvaliacao() { return dataAvaliacao; }
    public void setDataAvaliacao(LocalDate dataAvaliacao) { this.dataAvaliacao = dataAvaliacao; }

    public Boolean getPlanoGerado() { return planoGerado; }
    public void setPlanoGerado(Boolean planoGerado) { this.planoGerado = planoGerado; }
}
