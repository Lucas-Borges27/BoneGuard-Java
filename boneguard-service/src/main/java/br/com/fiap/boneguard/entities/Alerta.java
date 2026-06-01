package br.com.fiap.boneguard.entities;

import br.com.fiap.boneguard.enums.StatusAlerta;
import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "TB_ALERTA_BONEGUARD")
public class Alerta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "paciente_id", nullable = false)
    private Paciente paciente;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "avaliacao_id", nullable = false)
    private Avaliacao avaliacao;

    @Column(name = "mensagem", nullable = false, length = 500)
    private String mensagem;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 10)
    private StatusAlerta status;

    @Column(name = "data_criacao", nullable = false)
    private LocalDate dataCriacao;

    public Alerta() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Paciente getPaciente() { return paciente; }
    public void setPaciente(Paciente paciente) { this.paciente = paciente; }

    public Avaliacao getAvaliacao() { return avaliacao; }
    public void setAvaliacao(Avaliacao avaliacao) { this.avaliacao = avaliacao; }

    public String getMensagem() { return mensagem; }
    public void setMensagem(String mensagem) { this.mensagem = mensagem; }

    public StatusAlerta getStatus() { return status; }
    public void setStatus(StatusAlerta status) { this.status = status; }

    public LocalDate getDataCriacao() { return dataCriacao; }
    public void setDataCriacao(LocalDate dataCriacao) { this.dataCriacao = dataCriacao; }
}
