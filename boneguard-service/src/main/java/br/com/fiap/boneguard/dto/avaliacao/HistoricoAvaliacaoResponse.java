package br.com.fiap.boneguard.dto.avaliacao;

import br.com.fiap.boneguard.entities.Avaliacao;

import java.util.List;

public record HistoricoAvaliacaoResponse(
        Long pacienteId,
        List<AvaliacaoResponse> avaliacoes,
        Double primeiroScore,
        Double ultimoScore,
        String tendencia
) {
    public static HistoricoAvaliacaoResponse from(Long pacienteId, List<Avaliacao> avaliacoes) {
        if (avaliacoes.isEmpty()) {
            return new HistoricoAvaliacaoResponse(pacienteId, List.of(), null, null, "SEM_HISTORICO");
        }

        // A lista já vem ordenada por data DESC (mais recente primeiro)
        double ultimoScore  = avaliacoes.get(0).getScoreRisco();
        double primeiroScore = avaliacoes.get(avaliacoes.size() - 1).getScoreRisco();

        String tendencia;
        double delta = ultimoScore - primeiroScore;
        if (Math.abs(delta) < 5.0) {
            tendencia = "ESTAVEL";
        } else if (delta < 0) {
            tendencia = "MELHORA";
        } else {
            tendencia = "PIORA";
        }

        List<AvaliacaoResponse> responses = avaliacoes.stream()
                .map(AvaliacaoResponse::from)
                .toList();

        return new HistoricoAvaliacaoResponse(pacienteId, responses, primeiroScore, ultimoScore, tendencia);
    }
}
