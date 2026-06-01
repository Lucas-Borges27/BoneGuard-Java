package br.com.fiap.boneguard.dto.paciente;

import br.com.fiap.boneguard.entities.Paciente;
import br.com.fiap.boneguard.enums.NivelAtividade;
import br.com.fiap.boneguard.enums.Sexo;
import org.springframework.hateoas.RepresentationModel;

import java.time.LocalDate;

public class PacienteResponse extends RepresentationModel<PacienteResponse> {

    private Long id;
    private String nome;
    private Integer idade;
    private Sexo sexo;
    private Double peso;
    private Boolean historicoFamiliar;
    private NivelAtividade nivelAtividade;
    private Boolean alimentacaoCalcio;
    private LocalDate dataCadastro;

    public static PacienteResponse from(Paciente p) {
        PacienteResponse r = new PacienteResponse();
        r.id = p.getId();
        r.nome = p.getNome();
        r.idade = p.getIdade();
        r.sexo = p.getSexo();
        r.peso = p.getPeso();
        r.historicoFamiliar = p.getHistoricoFamiliar();
        r.nivelAtividade = p.getNivelAtividade();
        r.alimentacaoCalcio = p.getAlimentacaoCalcio();
        r.dataCadastro = p.getDataCadastro();
        return r;
    }

    public Long getId() { return id; }
    public String getNome() { return nome; }
    public Integer getIdade() { return idade; }
    public Sexo getSexo() { return sexo; }
    public Double getPeso() { return peso; }
    public Boolean getHistoricoFamiliar() { return historicoFamiliar; }
    public NivelAtividade getNivelAtividade() { return nivelAtividade; }
    public Boolean getAlimentacaoCalcio() { return alimentacaoCalcio; }
    public LocalDate getDataCadastro() { return dataCadastro; }
}
