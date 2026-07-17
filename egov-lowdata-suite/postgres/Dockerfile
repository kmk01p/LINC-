FROM postgres:16.3

COPY gov-portal/src/main/resources/schema.sql /docker-entrypoint-initdb.d/10-core-schema.sql
COPY gov-portal/src/main/resources/schema-project.sql /docker-entrypoint-initdb.d/20-project-schema.sql
COPY gov-portal/src/main/resources/schema-rbac.sql /docker-entrypoint-initdb.d/30-rbac-schema.sql
RUN chmod 644 /docker-entrypoint-initdb.d/*.sql
