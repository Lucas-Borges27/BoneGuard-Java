package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.auth.AuthResponse;
import br.com.fiap.boneguard.dto.auth.LoginRequest;
import br.com.fiap.boneguard.dto.auth.RegisterRequest;
import br.com.fiap.boneguard.entities.Paciente;
import br.com.fiap.boneguard.enums.NivelAtividade;
import br.com.fiap.boneguard.exception.ValidationException;
import br.com.fiap.boneguard.repositories.PacienteRepository;
import br.com.fiap.boneguard.security.JwtService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class AuthServiceImpl implements AuthService {

    private final PacienteRepository pacienteRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;

    public AuthServiceImpl(PacienteRepository pacienteRepository,
                           PasswordEncoder passwordEncoder,
                           JwtService jwtService,
                           AuthenticationManager authenticationManager,
                           UserDetailsService userDetailsService) {
        this.pacienteRepository = pacienteRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.userDetailsService = userDetailsService;
    }

    @Override
    public AuthResponse register(RegisterRequest request) {
        if (pacienteRepository.existsByEmail(request.email())) {
            throw new ValidationException("E-mail já cadastrado: " + request.email());
        }

        Paciente paciente = new Paciente();
        paciente.setEmail(request.email());
        paciente.setSenha(passwordEncoder.encode(request.senha()));
        paciente.setNome(request.nome());
        paciente.setIdade(request.idade());
        paciente.setSexo(request.sexo());
        paciente.setPeso(request.peso());
        paciente.setHistoricoFamiliar(request.historicoFamiliar() != null ? request.historicoFamiliar() : Boolean.FALSE);
        paciente.setNivelAtividade(request.nivelAtividade() != null ? request.nivelAtividade() : NivelAtividade.SEDENTARIO);
        paciente.setAlimentacaoCalcio(request.alimentacaoCalcio() != null ? request.alimentacaoCalcio() : Boolean.FALSE);
        paciente.setDataCadastro(LocalDate.now());

        Paciente saved = pacienteRepository.save(paciente);

        UserDetails userDetails = userDetailsService.loadUserByUsername(request.email());
        String token = jwtService.generateToken(userDetails);
        return new AuthResponse(token, request.email(), saved.getId());
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.senha())
        );
        UserDetails userDetails = userDetailsService.loadUserByUsername(request.email());
        Paciente paciente = pacienteRepository.findByEmail(request.email()).orElseThrow();
        String token = jwtService.generateToken(userDetails);
        return new AuthResponse(token, request.email(), paciente.getId());
    }
}
