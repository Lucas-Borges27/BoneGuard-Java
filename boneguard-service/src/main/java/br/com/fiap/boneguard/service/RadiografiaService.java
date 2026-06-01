package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.entities.Radiografia;
import org.springframework.web.multipart.MultipartFile;

public interface RadiografiaService {
    Radiografia analisar(Long avaliacaoId, MultipartFile imagem);
}
