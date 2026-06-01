package br.com.fiap.boneguard.entities;

import br.com.fiap.boneguard.entities.converter.BooleanSnConverter;
import br.com.fiap.boneguard.enums.NivelAtividade;
import br.com.fiap.boneguard.enums.Sexo;
import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "TB_PACIENTE_BONEGUARD")
public class Paciente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nome", nullable = false, length = 150)
    private String nome;

    @Column(name = "idade", nullable = false)
    private Integer idade;

    @Enumerated(EnumType.STRING)
    @Column(name = "sexo", nullable = false, length = 1)
    private Sexo sexo;

    @Column(name = "peso", nullable = false)
    private Double peso;

    @Convert(converter = BooleanSnConverter.class)
    @Column(name = "historico_familiar", nullable = false, length = 1)
    private Boolean historicoFamiliar;

    @Enumerated(EnumType.STRING)
    @Column(name = "nivel_atividade", nullable = false, length = 20)
    private NivelAtividade nivelAtividade;

    @Convert(converter = BooleanSnConverter.class)
    @Column(name = "alimentacao_calcio", nullable = false, length = 1)
    private Boolean alimentacaoCalcio;

    @Column(name = "data_cadastro", nullable = false)
    private LocalDate dataCadastro;

    @Column(name = "email", unique = true, length = 200)
    private String email;

    @Column(name = "senha", length = 200)
    private String senha;

    @Column(name = "role", nullable = false, length = 10)
    private String role = "USER";

    public Paciente() {
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public Integer getIdade() { return idade; }
    public void setIdade(Integer idade) { this.idade = idade; }

    public Sexo getSexo() { return sexo; }
    public void setSexo(Sexo sexo) { this.sexo = sexo; }

    public Double getPeso() { return peso; }
    public void setPeso(Double peso) { this.peso = peso; }

    public Boolean getHistoricoFamiliar() { return historicoFamiliar; }
    public void setHistoricoFamiliar(Boolean historicoFamiliar) { this.historicoFamiliar = historicoFamiliar; }

    public NivelAtividade getNivelAtividade() { return nivelAtividade; }
    public void setNivelAtividade(NivelAtividade nivelAtividade) { this.nivelAtividade = nivelAtividade; }

    public Boolean getAlimentacaoCalcio() { return alimentacaoCalcio; }
    public void setAlimentacaoCalcio(Boolean alimentacaoCalcio) { this.alimentacaoCalcio = alimentacaoCalcio; }

    public LocalDate getDataCadastro() { return dataCadastro; }
    public void setDataCadastro(LocalDate dataCadastro) { this.dataCadastro = dataCadastro; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
