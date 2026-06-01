package br.com.fiap.boneguard.entities;

import br.com.fiap.boneguard.entities.converter.BooleanSnConverter;
import br.com.fiap.boneguard.enums.CategoriaPlano;
import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "TB_PLANO_SAUDE_BONEGUARD")
public class PlanoSaude {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "avaliacao_id", nullable = false)
    private Avaliacao avaliacao;

    @Enumerated(EnumType.STRING)
    @Column(name = "categoria", nullable = false, length = 10)
    private CategoriaPlano categoria;

    @Column(name = "descricao", nullable = false, length = 2000)
    private String descricao;

    @Convert(converter = BooleanSnConverter.class)
    @Column(name = "ativo", nullable = false, length = 1)
    private Boolean ativo;

    @Column(name = "data_criacao", nullable = false)
    private LocalDate dataCriacao;

    public PlanoSaude() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Avaliacao getAvaliacao() { return avaliacao; }
    public void setAvaliacao(Avaliacao avaliacao) { this.avaliacao = avaliacao; }

    public CategoriaPlano getCategoria() { return categoria; }
    public void setCategoria(CategoriaPlano categoria) { this.categoria = categoria; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public Boolean getAtivo() { return ativo; }
    public void setAtivo(Boolean ativo) { this.ativo = ativo; }

    public LocalDate getDataCriacao() { return dataCriacao; }
    public void setDataCriacao(LocalDate dataCriacao) { this.dataCriacao = dataCriacao; }
}
