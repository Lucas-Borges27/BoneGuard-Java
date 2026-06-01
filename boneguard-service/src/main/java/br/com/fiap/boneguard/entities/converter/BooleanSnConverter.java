package br.com.fiap.boneguard.entities.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class BooleanSnConverter implements AttributeConverter<Boolean, String> {

    @Override
    public String convertToDatabaseColumn(Boolean attribute) {
        if (attribute == null) return "N";
        return attribute ? "S" : "N";
    }

    @Override
    public Boolean convertToEntityAttribute(String dbData) {
        return "S".equalsIgnoreCase(dbData);
    }
}
