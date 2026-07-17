# UTF-8 인코딩 설정 가이드

이 문서는 프로젝트에서 UTF-8 인코딩 문제를 해결하기 위해 적용된 설정들을 설명합니다.

## 문제 상황

한글이 `ìí°ì¤í¼ì    ë³´` 같은 깨진 글자로 표시되는 경우, 이는 인코딩 문제입니다.

## 적용된 해결책

### 1. Maven 빌드 설정 (pom.xml)

```xml
<properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    <maven.compiler.encoding>UTF-8</maven.compiler.encoding>
</properties>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <encoding>UTF-8</encoding>
            </configuration>
        </plugin>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-resources-plugin</artifactId>
            <configuration>
                <encoding>UTF-8</encoding>
            </configuration>
        </plugin>
    </plugins>
</build>
```

**위치**: `/gov-portal/pom.xml:13-15, 196, 204`

### 2. Spring Boot 설정 (application.yml)

```yaml
spring:
  http:
    encoding:
      charset: UTF-8
      enabled: true
      force: true
  messages:
    encoding: UTF-8
```

**위치**: `/gov-portal/src/main/resources/application.yml:20-26`

### 3. Web Application 필터 (web.xml)

```xml
<filter>
    <filter-name>encodingFilter</filter-name>
    <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    <init-param>
        <param-name>encoding</param-name>
        <param-value>UTF-8</param-value>
    </init-param>
    <init-param>
        <param-name>forceEncoding</param-name>
        <param-value>true</param-value>
    </init-param>
</filter>

<filter-mapping>
    <filter-name>encodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

**위치**: `/gov-portal/src/main/webapp/WEB-INF/web.xml:20-36`

**중요**: encodingFilter는 springSecurityFilterChain보다 **먼저** 정의되어야 합니다.

## 추가 확인 사항

### IDE 설정

#### IntelliJ IDEA
1. `File > Settings > Editor > File Encodings`
2. 다음 항목을 모두 `UTF-8`로 설정:
   - Global Encoding
   - Project Encoding
   - Default encoding for properties files

#### Eclipse
1. `Window > Preferences > General > Workspace`
2. Text file encoding을 `UTF-8`로 설정

### 데이터베이스 설정

PostgreSQL의 경우 데이터베이스와 클라이언트 인코딩 확인:

```sql
SHOW client_encoding;
SHOW server_encoding;
```

둘 다 `UTF8`이어야 합니다.

### Tomcat 설정

`server.xml`의 Connector에 다음 속성 추가:

```xml
<Connector port="8080"
           URIEncoding="UTF-8"
           useBodyEncodingForURI="true" />
```

## 재빌드 방법

설정 변경 후 반드시 재빌드해야 합니다:

```bash
cd gov-portal
mvn clean package
```

Docker를 사용하는 경우:

```bash
docker compose build gov-portal
docker compose up -d gov-portal
```

## 테스트 방법

### 1. 로그 확인
애플리케이션 로그에서 한글이 제대로 출력되는지 확인:

```bash
docker compose logs -f gov-portal
```

### 2. API 테스트
프로젝트 생성 API 호출 후 한글이 제대로 저장/조회되는지 확인:

```bash
curl -X POST http://localhost:8080/projects/create.do \
  -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
  -d "name=테스트 프로젝트&country=대한민국"
```

### 3. 데이터베이스 확인
PostgreSQL에서 직접 데이터 확인:

```bash
docker compose exec postgres psql -U postgres -d govportal
SELECT name FROM projects_biz LIMIT 5;
```

## 트러블슈팅

### 여전히 깨진 글자가 보이는 경우

1. **브라우저 인코딩 확인**: 브라우저에서 페이지 인코딩이 UTF-8로 설정되어 있는지 확인

2. **JSP 페이지 인코딩**: JSP 파일 상단에 다음 추가:
   ```jsp
   <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
   ```

3. **데이터베이스 연결 설정**: JDBC URL에 인코딩 파라미터 추가:
   ```
   jdbc:postgresql://localhost:5432/govportal?characterEncoding=UTF-8
   ```

4. **기존 데이터 복구**: 이미 깨진 데이터는 수동으로 복구해야 할 수 있습니다.

5. **전체 재시작**: 때로는 전체 시스템 재시작이 필요합니다:
   ```bash
   docker compose down
   docker compose up -d
   ```

## 관련 파일

- `/gov-portal/pom.xml` - Maven 빌드 설정
- `/gov-portal/src/main/resources/application.yml` - Spring 설정
- `/gov-portal/src/main/webapp/WEB-INF/web.xml` - 서블릿 필터 설정
- `/gov-portal/src/main/resources/schema-project.sql` - 데이터베이스 스키마

## 참고 자료

- [Spring CharacterEncodingFilter](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/filter/CharacterEncodingFilter.html)
- [Maven Project Encoding](https://maven.apache.org/general.html#encoding-warning)
- [PostgreSQL Character Set Support](https://www.postgresql.org/docs/current/multibyte.html)
