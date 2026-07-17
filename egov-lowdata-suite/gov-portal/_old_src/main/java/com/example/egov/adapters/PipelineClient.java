package com.example.egov.adapters;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * PipelineClient is responsible for publishing aggregated metrics to the
 * K-eGov endpoint. It wraps a WebClient and sends JSON payloads.
 */
@Component
public class PipelineClient {
    private final WebClient webClient;

    public PipelineClient(@Value("${KEGOV_ENDPOINT:http://kegov-mock:5000}") String baseUrl) {
        this.webClient = WebClient.builder().baseUrl(baseUrl).build();
    }
    // TODO: implement publish method
}