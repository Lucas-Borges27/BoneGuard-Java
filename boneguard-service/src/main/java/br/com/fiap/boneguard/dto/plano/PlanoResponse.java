package br.com.fiap.boneguard.dto.plano;

import br.com.fiap.boneguard.entities.PlanoSaude;
import br.com.fiap.boneguard.enums.CategoriaPlano;
import org.springframework.hateoas.RepresentationModel;

import java.time.LocalDate;

public class PlanoResponse extends RepresentationModel<PlanoResponse> {

    private Long id;
    private Long avaliacaoId;
    private CategoriaPlano categoria;
    private String descricao;
    private Boolean ativo;
    private LocalDate dataCriacao;

    public static PlanoResponse from(PlanoSaude p) {
        PlanoResponse r = new PlanoResponse();
        r.id = p.getId();
        r.avaliacaoId = p.getAvaliacao().getId();
        r.categoria = p.getCategoria();
        r.descricao = p.getDescricao();
        r.ativo = p.getAtivo();
        r.dataCriacao = p.getDataCriacao();
        return r;
    }

    public Long getId() { return id; }
    public Long getAvaliacaoId() { return avaliacaoId; }
    public CategoriaPlano getCategoria() { return categoria; }
    public String getDescricao() { return descricao; }
    public Boolean getAtivo() { return ativo; }
    public LocalDate getDataCriacao() { return dataCriacao; }
}
