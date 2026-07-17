package egovframework.govportal.admin.service;

import egovframework.govportal.admin.model.SystemSetting;
import egovframework.govportal.admin.model.SystemSetting.InputType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.annotation.PostConstruct;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class SystemSettingsService {

    private final Map<String, SystemSetting> registry = new ConcurrentHashMap<>();
    private final List<String> categoryOrder = new ArrayList<>();

    @PostConstruct
    public void initializeDefaults() {
        register("metabase.enabled", "Metabase 임베드 사용", "true",
            "대시보드에서 Metabase 카드/대시보드를 노출합니다.", "통합 연동", InputType.TOGGLE);
        register("metabase.refresh.interval", "Metabase 리프레시 주기(분)", "30",
            "내장된 Metabase 카드 데이터 새로고침 주기입니다.", "통합 연동", InputType.NUMBER);
        register("odk.sync.enabled", "ODK 동기화", "true",
            "ODK Central과의 자동 동기화를 수행합니다.", "데이터 파이프라인", InputType.TOGGLE);
        register("odk.sync.windowMinutes", "ODK 최근 동기화 범위(분)", "120",
            "동기화 작업 시 과거 데이터를 얼마나 포함할지 지정합니다.", "데이터 파이프라인", InputType.NUMBER);
        register("notifications.slack.webhook", "Slack 웹훅 URL", "",
            "시스템 알림을 전송할 Slack 웹훅 주소입니다.", "알림 & 경보", InputType.URL);
        register("notifications.email.sender", "알림 발신 이메일", "noreply@linc.gov",
            "경보/공지 발신자 이메일 주소입니다.", "알림 & 경보", InputType.TEXT);
        register("security.session.maxIdleMinutes", "세션 최대 유휴 시간(분)", "60",
            "지정 시간 이상 활동이 없으면 자동 로그아웃됩니다.", "보안 & 접근", InputType.NUMBER);
        register("security.audit.retentionDays", "감사 로그 보관 일수", "90",
            "감사 로그를 유지할 기간입니다.", "보안 & 접근", InputType.NUMBER);
        register("platform.banner.message", "상단 배너 메시지", "",
            "사용자에게 노출할 운영 공지를 입력하세요.", "플랫폼 운영", InputType.TEXT);
    }

    public List<SystemSetting> listAll() {
        return registry.values().stream()
            .sorted(Comparator.comparing(SystemSetting::getCategory)
                .thenComparing(SystemSetting::getLabel))
            .collect(Collectors.toList());
    }

    public Map<String, List<SystemSetting>> listGrouped() {
        Map<String, List<SystemSetting>> grouped = new LinkedHashMap<>();
        categoryOrder.forEach(category -> {
            List<SystemSetting> items = registry.values().stream()
                .filter(setting -> category.equals(setting.getCategory()))
                .sorted(Comparator.comparing(SystemSetting::getLabel))
                .collect(Collectors.toList());
            if (!items.isEmpty()) {
                grouped.put(category, items);
            }
        });
        return grouped;
    }

    public List<SystemSetting> updateSettings(Map<String, String> updates, UUID actorId) {
        if (updates == null) {
            updates = Collections.emptyMap();
        }
        Map<String, String> normalized = new LinkedHashMap<>(updates);
        registry.values().stream()
            .filter(setting -> setting.getInputType() == InputType.TOGGLE)
            .map(SystemSetting::getKey)
            .forEach(key -> normalized.putIfAbsent(key, "false"));

        List<SystemSetting> changed = new ArrayList<>();
        for (Map.Entry<String, String> entry : normalized.entrySet()) {
            SystemSetting setting = registry.get(entry.getKey());
            if (setting == null) {
                continue;
            }
            String incoming = sanitizeValue(setting, entry.getValue());
            if (!Objects.equals(setting.getValue(), incoming)) {
                setting.setValue(incoming);
                setting.setUpdatedAt(LocalDateTime.now());
                setting.setUpdatedBy(actorId);
                changed.add(setting);
            } else if (setting.getUpdatedAt() == null) {
                setting.setUpdatedAt(LocalDateTime.now());
                setting.setUpdatedBy(actorId);
            }
        }
        return changed;
    }

    public Optional<SystemSetting> findSetting(String key) {
        return Optional.ofNullable(registry.get(key));
    }

    private void register(String key,
                          String label,
                          String defaultValue,
                          String description,
                          String category,
                          InputType inputType) {
        if (!registry.containsKey(key)) {
            SystemSetting setting = new SystemSetting();
            setting.setKey(key);
            setting.setLabel(label);
            setting.setDefaultValue(defaultValue);
            setting.setValue(defaultValue);
            setting.setDescription(description);
            setting.setCategory(category);
            setting.setInputType(inputType);
            registry.put(key, setting);
            if (!categoryOrder.contains(category)) {
                categoryOrder.add(category);
            }
        }
    }

    private String sanitizeValue(SystemSetting setting, String rawValue) {
        if (setting.getInputType() == InputType.TOGGLE) {
            String candidate = Objects.toString(rawValue, "");
            return ("true".equalsIgnoreCase(candidate) || "on".equalsIgnoreCase(candidate)) ? "true" : "false";
        }
        if (setting.getInputType() == InputType.NUMBER) {
            String numeric = Objects.toString(rawValue, "").trim();
            if (!StringUtils.hasText(numeric)) {
                numeric = setting.getDefaultValue();
            }
            try {
                long number = Long.parseLong(numeric);
                return Long.toString(Math.max(number, 0));
            } catch (NumberFormatException ex) {
                return setting.getValue();
            }
        }
        return Objects.toString(rawValue, "").trim();
    }
}
