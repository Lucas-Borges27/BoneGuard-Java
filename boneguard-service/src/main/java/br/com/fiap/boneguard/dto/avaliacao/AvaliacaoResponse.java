package br.com.fiap.boneguard.dto.avaliacao;

import br.com.fiap.boneguard.entities.Avaliacao;
import br.com.fiap.boneguard.enums.Classificacao;
import org.springframework.hateoas.RepresentationModel;

import java.time.LocalDate;

public class AvaliacaoResponse extends RepresentationModel<AvaliacaoResponse> {

    private Long id;
    private Long pacienteId;
    private String pacienteNome;
    private Double scoreRisco;
    private Classificacao classificacao;
    private LocalDate dataAvaliacao;
    private Boolean planoGerado;

    public static AvaliacaoResponse from(Avaliacao a) {
        AvaliacaoResponse r = new AvaliacaoResponse();
        r.id = a.getId();
        r.pacienteId = a.getPaciente().getId();
        r.pacienteNome = a.getPaciente().getNome();
        r.scoreRisco = a.getScoreRisco();
        r.classificacao = a.getClassificacao();
        r.dataAvaliacao = a.getDataAvaliacao();
        r.planoGerado = a.getPlanoGerado();
        return r;
    }

    public Long getId() { return id; }
    public Long getPacienteId() { return pacienteId; }
    public String getPacienteNome() { return pacienteNome; }
    public Double getScoreRisco() { return scoreRisco; }
    public Classificacao getClassificacao() { return classificacao; }
    public LocalDate getDataAvaliacao() { return dataAvaliacao; }
    public Boolean getPlanoGerado() { return planoGerado; }
}
