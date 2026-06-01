package br.com.fiap.boneguard.dto.radiografia;

import br.com.fiap.boneguard.entities.Radiografia;
import br.com.fiap.boneguard.enums.ResultadoIA;
import org.springframework.hateoas.RepresentationModel;

import java.time.LocalDate;

public class RadiografiaResponse extends RepresentationModel<RadiografiaResponse> {

    private Long id;
    private Long avaliacaoId;
    private String caminhoImagem;
    private ResultadoIA resultadoIa;
    private Double confianca;
    private LocalDate dataAnalise;

    public static RadiografiaResponse from(Radiografia r) {
        RadiografiaResponse resp = new RadiografiaResponse();
        resp.id = r.getId();
        resp.avaliacaoId = r.getAvaliacao().getId();
        resp.caminhoImagem = r.getCaminhoImagem();
        resp.resultadoIa = r.getResultadoIa();
        resp.confianca = r.getConfianca();
        resp.dataAnalise = r.getDataAnalise();
        return resp;
    }

    public Long getId() { return id; }
    public Long getAvaliacaoId() { return avaliacaoId; }
    public String getCaminhoImagem() { return caminhoImagem; }
    public ResultadoIA getResultadoIa() { return resultadoIa; }
    public Double getConfianca() { return confianca; }
    public LocalDate getDataAnalise() { return dataAnalise; }
}
