package ru.mephi.orcestrafinal.dto;

import java.time.LocalDateTime;

public record Response(String text, String sentiment, LocalDateTime timestamp) {
    public Response(String text, String sentiment) {
        this(text, sentiment, LocalDateTime.now());
    }
}
