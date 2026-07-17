package com.example.egov.adapters;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * MetabaseClient holds base URL and embed secret for server-side embedding.
 * Actual API interactions are performed in metabase/bootstrap.py.
 */
@Component
public class MetabaseClient {
    private final String baseUrl;
    private final String embedSecret;
    private final String session;

    public MetabaseClient(@Value("${MB_BASE_URL:http://localhost:3000}") String baseUrl,
                          @Value("${MB_EMBED_SECRET:}") String embedSecret,
                          @Value("${MB_SESSION:}") String session) {
        this.baseUrl = baseUrl;
        this.embedSecret = embedSecret;
        this.session = session;
    }

    public String getBaseUrl() { return baseUrl; }
    public String getEmbedSecret() { return embedSecret; }
    public String getSession() { return session; }
}