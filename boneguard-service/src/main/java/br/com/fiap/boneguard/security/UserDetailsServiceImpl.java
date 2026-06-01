package br.com.fiap.boneguard.security;

import br.com.fiap.boneguard.repositories.PacienteRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final PacienteRepository pacienteRepository;

    public UserDetailsServiceImpl(PacienteRepository pacienteRepository) {
        this.pacienteRepository = pacienteRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        var paciente = pacienteRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Paciente não encontrado: " + email));
        return new User(
                paciente.getEmail(),
                paciente.getSenha(),
                List.of(new SimpleGrantedAuthority("ROLE_" + paciente.getRole()))
        );
    }
}
