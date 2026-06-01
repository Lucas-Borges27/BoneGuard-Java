package br.com.fiap.boneguard.enums;

public enum Classificacao {
    BAIXO, MODERADO, ALTO;

    public static Classificacao fromScore(double score) {
        if (score < 30) return BAIXO;
        if (score < 70) return MODERADO;
        return ALTO;
    }
}
