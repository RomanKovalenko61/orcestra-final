package ru.mephi.orcestrafinal.rest;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import ru.mephi.orcestrafinal.dto.Response;
import ru.mephi.orcestrafinal.dto.Sentiment;

@RestController
@RequestMapping("/api/sentiment")
public class MyController {

    @GetMapping
    public ResponseEntity<Response> answer(@RequestParam String text) {
        Sentiment sentiment;
        switch (text) {
            case "happy", "joyful", "excellent" -> sentiment = Sentiment.POSITIVE;
            case "sad", "terrible", "horrible" -> sentiment = Sentiment.NEGATIVE;
            default -> sentiment = Sentiment.NEUTRAL;
        }
        return ResponseEntity.ok(new Response(text, sentiment.name()));
    }
}
