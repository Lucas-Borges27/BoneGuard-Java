package br.com.fiap.notification.entities;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "TB_ALERTA_BONEGUARD")
public class Alerta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "paciente_id", nullable = false)
    private Long pacienteId;

    @Column(name = "avaliacao_id", nullable = false)
    private Long avaliacaoId;

    @Column(name = "mensagem", nullable = false, length = 500)
    private String mensagem;

    @Column(name = "status", nullable = false, length = 10)
    private String status;

    @Column(name = "data_criacao", nullable = false)
    private LocalDate dataCriacao;

    public Alerta() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getPacienteId() { return pacienteId; }
    public void setPacienteId(Long pacienteId) { this.pacienteId = pacienteId; }

    public Long getAvaliacaoId() { return avaliacaoId; }
    public void setAvaliacaoId(Long avaliacaoId) { this.avaliacaoId = avaliacaoId; }

    public String getMensagem() { return mensagem; }
    public void setMensagem(String mensagem) { this.mensagem = mensagem; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDate getDataCriacao() { return dataCriacao; }
    public void setDataCriacao(LocalDate dataCriacao) { this.dataCriacao = dataCriacao; }
}
