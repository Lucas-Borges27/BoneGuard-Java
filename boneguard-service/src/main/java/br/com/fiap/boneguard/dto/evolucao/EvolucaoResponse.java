package br.com.fiap.boneguard.dto.evolucao;

import br.com.fiap.boneguard.entities.Evolucao;
import br.com.fiap.boneguard.enums.NivelAtividade;
import org.springframework.hateoas.RepresentationModel;

import java.time.LocalDate;

public class EvolucaoResponse extends RepresentationModel<EvolucaoResponse> {

    private Long id;
    private Long pacienteId;
    private Double pesoAtual;
    private NivelAtividade nivelAtividadeAtual;
    private String observacoes;
    private LocalDate dataRegistro;

    public static EvolucaoResponse from(Evolucao e) {
        EvolucaoResponse r = new EvolucaoResponse();
        r.id = e.getId();
        r.pacienteId = e.getPaciente().getId();
        r.pesoAtual = e.getPesoAtual();
        r.nivelAtividadeAtual = e.getNivelAtividadeAtual();
        r.observacoes = e.getObservacoes();
        r.dataRegistro = e.getDataRegistro();
        return r;
    }

    public Long getId() { return id; }
    public Long getPacienteId() { return pacienteId; }
    public Double getPesoAtual() { return pesoAtual; }
    public NivelAtividade getNivelAtividadeAtual() { return nivelAtividadeAtual; }
    public String getObservacoes() { return observacoes; }
    public LocalDate getDataRegistro() { return dataRegistro; }
}
