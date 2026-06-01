package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.dto.auth.AuthResponse;
import br.com.fiap.boneguard.dto.auth.LoginRequest;
import br.com.fiap.boneguard.dto.auth.RegisterRequest;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
}
