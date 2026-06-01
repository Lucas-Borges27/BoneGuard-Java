package br.com.fiap.boneguard.dto.auth;

public record AuthResponse(String token, String email, Long pacienteId) {
}
