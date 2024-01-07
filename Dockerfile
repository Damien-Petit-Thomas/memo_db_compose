FROM postgres:latest


ENV POSTGRES_DB=memo \
    POSTGRES_USER=memo \
    POSTGRES_PASSWORD=memo 

RUN rm -rf /docker-entrypoint-initdb.d/
COPY ./init-data.sql /docker-entrypoint-initdb.d/

EXPOSE 5433
