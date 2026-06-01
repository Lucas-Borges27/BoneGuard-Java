package br.com.fiap.boneguard.entities;

import br.com.fiap.boneguard.enums.ResultadoIA;
import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "TB_RADIOGRAFIA_BONEGUARD")
public class Radiografia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "avaliacao_id", nullable = false)
    private Avaliacao avaliacao;

    @Column(name = "caminho_imagem", length = 500)
    private String caminhoImagem;

    @Enumerated(EnumType.STRING)
    @Column(name = "resultado_ia", nullable = false, length = 15)
    private ResultadoIA resultadoIa;

    @Column(name = "confianca", nullable = false)
    private Double confianca;

    @Column(name = "data_analise", nullable = false)
    private LocalDate dataAnalise;

    public Radiografia() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Avaliacao getAvaliacao() { return avaliacao; }
    public void setAvaliacao(Avaliacao avaliacao) { this.avaliacao = avaliacao; }

    public String getCaminhoImagem() { return caminhoImagem; }
    public void setCaminhoImagem(String caminhoImagem) { this.caminhoImagem = caminhoImagem; }

    public ResultadoIA getResultadoIa() { return resultadoIa; }
    public void setResultadoIa(ResultadoIA resultadoIa) { this.resultadoIa = resultadoIa; }

    public Double getConfianca() { return confianca; }
    public void setConfianca(Double confianca) { this.confianca = confianca; }

    public LocalDate getDataAnalise() { return dataAnalise; }
    public void setDataAnalise(LocalDate dataAnalise) { this.dataAnalise = dataAnalise; }
}
