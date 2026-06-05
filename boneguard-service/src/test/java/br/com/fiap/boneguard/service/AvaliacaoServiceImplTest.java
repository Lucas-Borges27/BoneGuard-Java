package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.avaliacao.AvaliacaoRequest;
import br.com.fiap.boneguard.entities.Avaliacao;
import br.com.fiap.boneguard.entities.Paciente;
import br.com.fiap.boneguard.enums.Classificacao;
import br.com.fiap.boneguard.enums.NivelAtividade;
import br.com.fiap.boneguard.enums.Sexo;
import br.com.fiap.boneguard.exception.ResourceNotFoundException;
import br.com.fiap.boneguard.exception.ValidationException;
import br.com.fiap.boneguard.external_interface.rabbitmq.AlertaPublisher;
import br.com.fiap.boneguard.repositories.AvaliacaoRepository;
import br.com.fiap.boneguard.repositories.PacienteRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("AvaliacaoServiceImpl — testes de unidade")
class AvaliacaoServiceImplTest {

    @Mock private AvaliacaoRepository avaliacaoRepository;
    @Mock private PacienteRepository pacienteRepository;
    @Mock private AlertaPublisher alertaPublisher;

    @InjectMocks private AvaliacaoServiceImpl service;

    private Paciente paciente;

    @BeforeEach
    void setUp() {
        paciente = new Paciente();
        paciente.setId(1L);
        paciente.setNome("Lucas Borges");
        paciente.setIdade(22);
        paciente.setSexo(Sexo.M);
        paciente.setPeso(75.0);
        paciente.setHistoricoFamiliar(false);
        paciente.setNivelAtividade(NivelAtividade.ATIVO);
        paciente.setAlimentacaoCalcio(true);
        paciente.setDataCadastro(LocalDate.now());
    }

    // ─── criar ────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("criar — score BAIXO não publica alerta")
    void criar_scoreBaixo_naoPublicaAlerta() {
        // Arrange
        var request = new AvaliacaoRequest(1L, 20.0);
        when(pacienteRepository.findById(1L)).thenReturn(Optional.of(paciente));
        when(avaliacaoRepository.save(any())).thenAnswer(inv -> {
            Avaliacao a = inv.getArgument(0);
            a.setId(10L);
            return a;
        });

        // Act
        Avaliacao resultado = service.criar(request);

        // Assert
        assertThat(resultado.getClassificacao()).isEqualTo(Classificacao.BAIXO);
        assertThat(resultado.getScoreRisco()).isEqualTo(20.0);
        assertThat(resultado.getPlanoGerado()).isFalse();
        verify(alertaPublisher, never()).publicar(any());
    }

    @Test
    @DisplayName("criar — score ALTO publica alerta via RabbitMQ")
    void criar_scoreAlto_publicaAlerta() {
        // Arrange
        var request = new AvaliacaoRequest(1L, 80.0);
        when(pacienteRepository.findById(1L)).thenReturn(Optional.of(paciente));
        when(avaliacaoRepository.save(any())).thenAnswer(inv -> {
            Avaliacao a = inv.getArgument(0);
            a.setId(11L);
            return a;
        });

        // Act
        Avaliacao resultado = service.criar(request);

        // Assert
        assertThat(resultado.getClassificacao()).isEqualTo(Classificacao.ALTO);
        verify(alertaPublisher, times(1)).publicar(any());
    }

    @Test
    @DisplayName("criar — score MODERADO não publica alerta")
    void criar_scoreMode_naoPublicaAlerta() {
        // Arrange
        var request = new AvaliacaoRequest(1L, 50.0);
        when(pacienteRepository.findById(1L)).thenReturn(Optional.of(paciente));
        when(avaliacaoRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // Act
        Avaliacao resultado = service.criar(request);

        // Assert
        assertThat(resultado.getClassificacao()).isEqualTo(Classificacao.MODERADO);
        verify(alertaPublisher, never()).publicar(any());
    }

    @Test
    @DisplayName("criar — score negativo lança ValidationException")
    void criar_scoreNegativo_lancaValidation() {
        // Arrange
        var request = new AvaliacaoRequest(1L, -1.0);

        // Act & Assert
        assertThatThrownBy(() -> service.criar(request))
                .isInstanceOf(ValidationException.class)
                .hasMessageContaining("Score deve estar entre 0 e 100");

        verify(avaliacaoRepository, never()).save(any());
    }

    @Test
    @DisplayName("criar — score acima de 100 lança ValidationException")
    void criar_scoreAcima100_lancaValidation() {
        // Arrange
        var request = new AvaliacaoRequest(1L, 101.0);

        // Act & Assert
        assertThatThrownBy(() -> service.criar(request))
                .isInstanceOf(ValidationException.class);
    }

    @Test
    @DisplayName("criar — paciente inexistente lança ResourceNotFoundException")
    void criar_pacienteInexistente_lancaNotFound() {
        // Arrange
        var request = new AvaliacaoRequest(99L, 50.0);
        when(pacienteRepository.findById(99L)).thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> service.criar(request))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("criar — data da avaliação é preenchida como hoje")
    void criar_dataAvaliacao_ehHoje() {
        // Arrange
        var request = new AvaliacaoRequest(1L, 30.0);
        when(pacienteRepository.findById(1L)).thenReturn(Optional.of(paciente));

        ArgumentCaptor<Avaliacao> captor = ArgumentCaptor.forClass(Avaliacao.class);
        when(avaliacaoRepository.save(captor.capture())).thenAnswer(inv -> inv.getArgument(0));

        // Act
        service.criar(request);

        // Assert
        assertThat(captor.getValue().getDataAvaliacao()).isEqualTo(LocalDate.now());
    }

    // ─── buscarPorId ──────────────────────────────────────────────────────────

    @Test
    @DisplayName("buscarPorId — retorna avaliação existente")
    void buscarPorId_existente_retornaAvaliacao() {
        // Arrange
        Avaliacao avaliacao = new Avaliacao();
        avaliacao.setId(5L);
        when(avaliacaoRepository.findByIdWithPaciente(5L)).thenReturn(Optional.of(avaliacao));

        // Act
        Avaliacao resultado = service.buscarPorId(5L);

        // Assert
        assertThat(resultado.getId()).isEqualTo(5L);
    }

    @Test
    @DisplayName("buscarPorId — ID inexistente lança ResourceNotFoundException")
    void buscarPorId_inexistente_lancaNotFound() {
        // Act & Assert
        assertThatThrownBy(() -> service.buscarPorId(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // ─── buscarHistoricoPorPaciente ───────────────────────────────────────────

    @Test
    @DisplayName("buscarHistoricoPorPaciente — paciente inexistente lança ResourceNotFoundException")
    void buscarHistorico_pacienteInexistente_lancaNotFound() {
        // Arrange
        when(pacienteRepository.existsById(99L)).thenReturn(false);

        // Act & Assert
        assertThatThrownBy(() -> service.buscarHistoricoPorPaciente(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("buscarHistoricoPorPaciente — retorna lista do repositório")
    void buscarHistorico_pacienteExistente_retornaLista() {
        // Arrange
        when(pacienteRepository.existsById(1L)).thenReturn(true);
        when(avaliacaoRepository.findByPacienteIdOrderByDataAvaliacaoDesc(1L))
                .thenReturn(List.of(new Avaliacao(), new Avaliacao()));

        // Act
        var lista = service.buscarHistoricoPorPaciente(1L);

        // Assert
        assertThat(lista).hasSize(2);
    }
}
