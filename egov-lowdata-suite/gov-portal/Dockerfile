FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /workspace

# Copy Maven descriptor first to leverage layer caching
COPY pom.xml .
COPY maven_repository /tmp/maven_repository
RUN mkdir -p /root/.m2/repository \
    && cp -R /tmp/maven_repository/. /root/.m2/repository/ \
    && rm -rf /tmp/maven_repository
RUN find /root/.m2 -name _remote.repositories -delete
RUN mvn -B org.apache.maven.plugins:maven-dependency-plugin:3.7.0:get \
        -Dartifact=com.lowagie:itext:2.1.7 \
        -Dtransitive=false \
    && mvn -B org.apache.maven.plugins:maven-install-plugin:3.1.2:install-file \
        -DgroupId=com.lowagie \
        -DartifactId=itext \
        -Dversion=2.1.7.js5-SNAPSHOT \
        -Dpackaging=jar \
        -Dfile=/root/.m2/repository/com/lowagie/itext/2.1.7/itext-2.1.7.jar \
        -DgeneratePom=true
RUN mkdir -p /tmp/uowstub \
    && echo "placeholder" > /tmp/uowstub/placeholder.txt \
    && jar --create --file /tmp/uow-6.0.2.17.jar -C /tmp/uowstub . \
    && mvn -B org.apache.maven.plugins:maven-install-plugin:3.1.2:install-file \
        -DgroupId=com.ibm.websphere \
        -DartifactId=uow \
        -Dversion=6.0.2.17 \
        -Dpackaging=jar \
        -Dfile=/tmp/uow-6.0.2.17.jar \
        -DgeneratePom=true
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B -DskipTests package
RUN ARTIFACT=$(ls target/*.war | head -n 1) \
    && cp "$ARTIFACT" /workspace/app.war

FROM tomcat:9.0-jdk17
WORKDIR /usr/local/tomcat

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /workspace/app.war /usr/local/tomcat/webapps/ROOT.war
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["catalina.sh", "run"]
