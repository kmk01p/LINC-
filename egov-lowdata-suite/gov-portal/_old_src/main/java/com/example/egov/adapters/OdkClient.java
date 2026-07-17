package com.example.egov.adapters;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * OdkClient wraps calls to ODK Central's REST API. Methods return Mono/Flux or
 * synchronous results. Implementation is incomplete and should be expanded to
 * create projects, upload forms, publish drafts, and pull submissions.
 */
@Component
public class OdkClient {
    private static final Logger log = LoggerFactory.getLogger(OdkClient.class);
    private final WebClient webClient;

    public OdkClient(@Value("${ODK_BASE_URL:http://localhost:8383}") String baseUrl,
                     @Value("${ODK_API_TOKEN:}") String token) {
        this.webClient = WebClient.builder()
                .baseUrl(baseUrl + "/v1")
                .defaultHeader("Authorization", "Bearer " + token)
                .build();
    }
    // TODO: implement methods for createProject, uploadForm, publishDraft, pullSubmissions
}