FROM postgres:latest


ENV POSTGRES_DB=memo \
    POSTGRES_USER=memo \
    POSTGRES_PASSWORD=memo 

RUN rm -rf /docker-entrypoint-initdb.d/

# le fichier init-data.sql contenant la structure de la bdd sera exécuté au démarrage du conteneur dans le dossier 
#docker-entrypoint-initdb.d qui est le dossier par défaut pour exécuter des scripts SQL

COPY ./init-data.sql /docker-entrypoint-initdb.d/

EXPOSE 5433
