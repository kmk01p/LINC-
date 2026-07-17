# 가비아 호스팅 배포 가이드

## 목차
1. [사전 준비](#사전-준비)
2. [데이터베이스 설정](#데이터베이스-설정)
3. [애플리케이션 배포](#애플리케이션-배포)
4. [설정 파일 업데이트](#설정-파일-업데이트)
5. [배포 확인](#배포-확인)
6. [문제 해결](#문제-해결)

---

## 사전 준비

### 필요한 정보
- **도메인**: forhim.kr
- **SFTP 접속 정보**:
  - 호스트: forhim.kr
  - 포트: 22
  - 사용자: william7872ksh
  - 비밀번호: (가비아에서 설정한 비밀번호)

- **DB 접속 정보**:
  - 호스트: db.forhim.kr
  - 포트: 3306
  - 데이터베이스: dbwilliam7872ksh
  - 사용자: william7872ksh
  - 비밀번호: (가비아에서 설정한 비밀번호)

### 필요한 도구
- FileZilla 또는 WinSCP (SFTP 클라이언트)
- MySQL Workbench 또는 phpMyAdmin (DB 관리)
- 터미널/SSH 클라이언트

---

## 데이터베이스 설정

### 1. MySQL Workbench 또는 phpMyAdmin 접속

```
호스트: db.forhim.kr
포트: 3306
사용자: william7872ksh
데이터베이스: dbwilliam7872ksh
```

### 2. 스키마 생성

`deployment/mysql-schema.sql` 파일을 실행합니다.

**MySQL Workbench 사용 시:**
1. File > Open SQL Script 선택
2. `mysql-schema.sql` 파일 선택
3. Execute (번개 아이콘) 클릭

**phpMyAdmin 사용 시:**
1. 데이터베이스 선택
2. SQL 탭 선택
3. 파일 선택에서 `mysql-schema.sql` 업로드
4. 실행 클릭

### 3. 초기 데이터 삽입

`deployment/mysql-init-data.sql` 파일을 실행합니다.

**초기 관리자 계정:**
- 아이디: `admin`
- 비밀번호: `admin123`
- 이메일: `admin@forhim.kr`

⚠️ **중요**: 첫 로그인 후 반드시 비밀번호를 변경하세요!

---

## 애플리케이션 배포

### 1. WAR 파일 빌드

로컬 환경에서 다음 명령어를 실행합니다:

```bash
cd gov-portal
mvn clean package -DskipTests
```

빌드가 완료되면 `target/gov-portal.war` 파일이 생성됩니다.

### 2. 설정 파일 준비

`deployment/application-prod.properties` 파일을 열고 다음 정보를 업데이트합니다:

```properties
# DB 비밀번호 업데이트
spring.datasource.password=실제_DB_비밀번호

# ODK Central 정보 (선택사항)
odk.central.url=https://your-odk-central.com
odk.central.email=admin@example.com
odk.central.password=your-odk-password
```

### 3. SFTP로 파일 업로드

**FileZilla 사용:**
1. 새 사이트 추가
   - 호스트: forhim.kr
   - 프로토콜: SFTP
   - 로그온 유형: 일반
   - 사용자: william7872ksh
   - 비밀번호: (가비아 비밀번호)
   - 포트: 22

2. 접속 후 다음 경로로 이동:
   ```
   /home/hosting_users/william7872ksh/tomcat/webapps/
   ```

3. 기존 ROOT 폴더 백업 (있다면):
   ```
   ROOT 폴더를 ROOT_backup_20251111로 이름 변경
   ```

4. `gov-portal.war` 파일을 업로드하고 이름을 `ROOT.war`로 변경

5. 설정 파일 업로드:
   ```
   /home/hosting_users/william7872ksh/tomcat/conf/
   ```
   위 경로에 `application-prod.properties` 업로드

### 4. SSH로 서버 접속 및 재시작

```bash
ssh william7872ksh@forhim.kr

# Tomcat 재시작
cd ~/tomcat/bin
./shutdown.sh
sleep 5
./startup.sh

# 로그 확인
tail -f ~/tomcat/logs/catalina.out
```

---

## 설정 파일 업데이트

### 애플리케이션이 설정 파일을 찾도록 하기

`~/tomcat/bin/setenv.sh` 파일 생성 또는 수정:

```bash
vi ~/tomcat/bin/setenv.sh
```

다음 내용 추가:

```bash
#!/bin/bash
export JAVA_OPTS="$JAVA_OPTS -Dspring.profiles.active=prod"
export JAVA_OPTS="$JAVA_OPTS -Dspring.config.location=file:/home/hosting_users/william7872ksh/tomcat/conf/application-prod.properties"
```

저장 후 실행 권한 부여:

```bash
chmod +x ~/tomcat/bin/setenv.sh
```

---

## 배포 확인

### 1. 웹 브라우저에서 접속

```
https://forhim.kr
```

### 2. 로그인 테스트

- 아이디: `admin`
- 비밀번호: `admin123`

### 3. 로그 확인

```bash
ssh william7872ksh@forhim.kr

# 애플리케이션 로그
tail -f ~/logs/app.log

# Tomcat 로그
tail -f ~/tomcat/logs/catalina.out

# 에러 로그
tail -f ~/tomcat/logs/localhost.*.log
```

---

## 문제 해결

### 1. 데이터베이스 연결 실패

**증상**: `CommunicationsException` 또는 `Access denied`

**해결**:
1. DB 비밀번호가 올바른지 확인
2. DB 호스트명 확인: `db.forhim.kr`
3. 가비아 관리 콘솔에서 DB 접속 가능 여부 확인

### 2. 404 에러 - 페이지를 찾을 수 없음

**해결**:
1. WAR 파일 이름이 `ROOT.war`인지 확인
2. WAR 파일이 자동으로 압축 해제되었는지 확인
3. Tomcat 재시작

### 3. 500 에러 - 서버 오류

**해결**:
1. 로그 확인:
   ```bash
   tail -f ~/tomcat/logs/catalina.out
   tail -f ~/logs/app.log
   ```
2. `application-prod.properties` 설정 확인
3. 데이터베이스 테이블이 모두 생성되었는지 확인

### 4. 정적 리소스 (CSS/JS) 로딩 실패

**해결**:
1. 웹 브라우저 캐시 삭제
2. JSP 파일의 리소스 경로 확인:
   ```jsp
   <link href="${pageContext.request.contextPath}/css/style.css" ...>
   ```

### 5. 메모리 부족

**해결**:
Tomcat 메모리 설정 조정 (`setenv.sh`):

```bash
export JAVA_OPTS="$JAVA_OPTS -Xms256m -Xmx512m -XX:MetaspaceSize=128m"
```

### 6. 로그 파일 경로 오류

**해결**:
로그 디렉토리 생성:

```bash
mkdir -p ~/logs
chmod 755 ~/logs
```

---

## 주요 경로 정리

```
/home/hosting_users/william7872ksh/
├── tomcat/
│   ├── webapps/
│   │   └── ROOT.war          # 메인 애플리케이션
│   ├── conf/
│   │   └── application-prod.properties  # 설정 파일
│   ├── logs/
│   │   ├── catalina.out      # Tomcat 로그
│   │   └── localhost.*.log   # 에러 로그
│   └── bin/
│       └── setenv.sh         # 환경 변수 설정
└── logs/
    └── app.log               # 애플리케이션 로그
```

---

## 추가 작업

### 1. HTTPS 설정 (이미 가비아에서 제공)

가비아 호스팅은 무료 SSL을 제공하므로 자동으로 HTTPS가 적용됩니다.

### 2. 정기 백업 설정

가비아에서 자동 백업을 제공합니다:
- 웹 백업: 매일 자동
- DB 백업: 매일 자동

추가 백업이 필요한 경우:
```bash
# DB 백업
mysqldump -h db.forhim.kr -u william7872ksh -p dbwilliam7872ksh > backup_$(date +%Y%m%d).sql
```

### 3. 모니터링

가비아 관리 콘솔에서 다음을 확인할 수 있습니다:
- 메모리 사용량
- 웹 트래픽
- DB 용량
- 에러 로그

---

## 연락처 및 지원

- 가비아 고객센터: 1544-4755
- 기술 지원: https://customer.gabia.com

---

## 버전 정보

- 작성일: 2025-11-11
- 애플리케이션 버전: 1.0.0
- Java 버전: 17
- MySQL 버전: 8.0
- Spring Boot 버전: 2.7.x
