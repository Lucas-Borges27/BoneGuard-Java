package br.com.fiap.boneguard.service;

import br.com.fiap.boneguard.entities.Avaliacao;
import br.com.fiap.boneguard.entities.Radiografia;
import br.com.fiap.boneguard.exception.ResourceNotFoundException;
import br.com.fiap.boneguard.external_interface.feign.VisionResponse;
import br.com.fiap.boneguard.external_interface.feign.VisionServiceClient;
import br.com.fiap.boneguard.repositories.AvaliacaoRepository;
import br.com.fiap.boneguard.repositories.RadiografiaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;

@Service
public class RadiografiaServiceImpl implements RadiografiaService {

    private static final Logger logger = LoggerFactory.getLogger(RadiografiaServiceImpl.class);

    private final RadiografiaRepository radiografiaRepository;
    private final AvaliacaoRepository avaliacaoRepository;
    private final VisionServiceClient visionServiceClient;

    public RadiografiaServiceImpl(RadiografiaRepository radiografiaRepository,
                                  AvaliacaoRepository avaliacaoRepository,
                                  VisionServiceClient visionServiceClient) {
        this.radiografiaRepository = radiografiaRepository;
        this.avaliacaoRepository = avaliacaoRepository;
        this.visionServiceClient = visionServiceClient;
    }

    @Override
    @Transactional
    public Radiografia analisar(Long avaliacaoId, MultipartFile imagem) {
        Avaliacao avaliacao = avaliacaoRepository.findById(avaliacaoId)
                .orElseThrow(() -> new ResourceNotFoundException("Avaliação", avaliacaoId));

        logger.info("Enviando radiografia para análise IA, avaliacao_id={}", avaliacaoId);
        VisionResponse visionResponse = visionServiceClient.analisarRadiografia(imagem);
        logger.info("Resultado IA: classificacao={} confianca={}", visionResponse.classificacao(), visionResponse.confianca());

        Radiografia radiografia = new Radiografia();
        radiografia.setAvaliacao(avaliacao);
        radiografia.setCaminhoImagem(imagem.getOriginalFilename());
        radiografia.setResultadoIa(visionResponse.classificacao());
        radiografia.setConfianca(visionResponse.confianca());
        radiografia.setDataAnalise(LocalDate.now());

        return radiografiaRepository.save(radiografia);
    }
}
