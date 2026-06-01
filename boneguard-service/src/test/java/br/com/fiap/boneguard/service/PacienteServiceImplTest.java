package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.paciente.PacienteRequest;
import br.com.fiap.boneguard.entities.Paciente;
import br.com.fiap.boneguard.enums.NivelAtividade;
import br.com.fiap.boneguard.enums.Sexo;
import br.com.fiap.boneguard.exception.ResourceNotFoundException;
import br.com.fiap.boneguard.repositories.PacienteRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("PacienteServiceImpl — testes de unidade")
class PacienteServiceImplTest {

    @Mock private PacienteRepository pacienteRepository;

    @InjectMocks private PacienteServiceImpl service;

    private PacienteRequest buildRequest(String nome) {
        return new PacienteRequest(nome, 30, Sexo.F, 60.0, false, NivelAtividade.MODERADO, true);
    }

    // ─── criar ────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("criar — persiste paciente com data de hoje")
    void criar_persistePacienteComDataHoje() {
        // Arrange
        var request = buildRequest("Maria Souza");
        ArgumentCaptor<Paciente> captor = ArgumentCaptor.forClass(Paciente.class);
        when(pacienteRepository.save(captor.capture())).thenAnswer(inv -> {
            Paciente p = inv.getArgument(0);
            p.setId(1L);
            return p;
        });

        // Act
        Paciente resultado = service.criar(request);

        // Assert
        assertThat(resultado.getId()).isEqualTo(1L);
        assertThat(captor.getValue().getNome()).isEqualTo("Maria Souza");
        assertThat(captor.getValue().getDataCadastro()).isEqualTo(LocalDate.now());
        assertThat(captor.getValue().getSexo()).isEqualTo(Sexo.F);
        assertThat(captor.getValue().getNivelAtividade()).isEqualTo(NivelAtividade.MODERADO);
    }

    @Test
    @DisplayName("criar — todos os campos do request são mapeados")
    void criar_mapeaTodosOsCampos() {
        // Arrange
        var request = new PacienteRequest("João", 45, Sexo.M, 80.0, true, NivelAtividade.SEDENTARIO, false);
        ArgumentCaptor<Paciente> captor = ArgumentCaptor.forClass(Paciente.class);
        when(pacienteRepository.save(captor.capture())).thenAnswer(inv -> inv.getArgument(0));

        // Act
        service.criar(request);

        // Assert
        Paciente salvo = captor.getValue();
        assertThat(salvo.getNome()).isEqualTo("João");
        assertThat(salvo.getIdade()).isEqualTo(45);
        assertThat(salvo.getSexo()).isEqualTo(Sexo.M);
        assertThat(salvo.getPeso()).isEqualTo(80.0);
        assertThat(salvo.getHistoricoFamiliar()).isTrue();
        assertThat(salvo.getNivelAtividade()).isEqualTo(NivelAtividade.SEDENTARIO);
        assertThat(salvo.getAlimentacaoCalcio()).isFalse();
    }

    // ─── buscarPorId ──────────────────────────────────────────────────────────

    @Test
    @DisplayName("buscarPorId — retorna paciente existente")
    void buscarPorId_existente_retorna() {
        // Arrange
        Paciente p = new Paciente();
        p.setId(42L);
        p.setNome("Carlos");
        when(pacienteRepository.findById(42L)).thenReturn(Optional.of(p));

        // Act
        Paciente resultado = service.buscarPorId(42L);

        // Assert
        assertThat(resultado.getId()).isEqualTo(42L);
        assertThat(resultado.getNome()).isEqualTo("Carlos");
    }

    @Test
    @DisplayName("buscarPorId — ID inexistente lança ResourceNotFoundException")
    void buscarPorId_inexistente_lancaException() {
        // Arrange
        when(pacienteRepository.findById(99L)).thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> service.buscarPorId(99L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("99");
    }

    // ─── atualizar ────────────────────────────────────────────────────────────

    @Test
    @DisplayName("atualizar — altera os dados e salva")
    void atualizar_alteraDadosESalva() {
        // Arrange
        Paciente existente = new Paciente();
        existente.setId(1L);
        existente.setNome("Nome Antigo");
        existente.setDataCadastro(LocalDate.of(2024, 1, 1));

        when(pacienteRepository.findById(1L)).thenReturn(Optional.of(existente));
        when(pacienteRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        var request = buildRequest("Nome Novo");

        // Act
        Paciente resultado = service.atualizar(1L, request);

        // Assert
        assertThat(resultado.getNome()).isEqualTo("Nome Novo");
        assertThat(resultado.getDataCadastro()).isEqualTo(LocalDate.of(2024, 1, 1)); // data não muda
        verify(pacienteRepository, times(1)).save(existente);
    }

    @Test
    @DisplayName("atualizar — ID inexistente lança ResourceNotFoundException")
    void atualizar_inexistente_lancaException() {
        // Arrange
        when(pacienteRepository.findById(99L)).thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> service.atualizar(99L, buildRequest("X")))
                .isInstanceOf(ResourceNotFoundException.class);

        verify(pacienteRepository, never()).save(any());
    }
}
