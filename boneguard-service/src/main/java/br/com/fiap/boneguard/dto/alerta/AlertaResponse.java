package br.com.fiap.boneguard.dto.alerta;

import br.com.fiap.boneguard.entities.Alerta;
import br.com.fiap.boneguard.enums.StatusAlerta;
import org.springframework.hateoas.RepresentationModel;

import java.time.LocalDate;

public class AlertaResponse extends RepresentationModel<AlertaResponse> {

    private Long id;
    private Long pacienteId;
    private Long avaliacaoId;
    private String mensagem;
    private StatusAlerta status;
    private LocalDate dataCriacao;

    public static AlertaResponse from(Alerta a) {
        AlertaResponse r = new AlertaResponse();
        r.id = a.getId();
        r.pacienteId = a.getPaciente().getId();
        r.avaliacaoId = a.getAvaliacao().getId();
        r.mensagem = a.getMensagem();
        r.status = a.getStatus();
        r.dataCriacao = a.getDataCriacao();
        return r;
    }

    public Long getId() { return id; }
    public Long getPacienteId() { return pacienteId; }
    public Long getAvaliacaoId() { return avaliacaoId; }
    public String getMensagem() { return mensagem; }
    public StatusAlerta getStatus() { return status; }
    public LocalDate getDataCriacao() { return dataCriacao; }
}
