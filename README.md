# fichiers de démarage de l'application

pour executer l'application

`docker-compose -f docker-compose-prod.yml up -d` ou
en developpemnent : ( bien spécifier les chemins pour les  points de montages des volumes ) 
`docker-compose -f docker-compose-dev.yml up -d`

par défaut l'application est accessible en local sur memo.localhost:80 
modifier le fichier Caddyfile pour changer le nom de domaine et le port d'écoute
pour un déploiement en production sur serveur distant : documentation en cours

## docker-comopose : la configuration suivante est pour le mmode developpement

```yml


# pou le developpemnt   
# docker-compose up -d  pour lancer les containers... l'application est accessiblepar defaut à  memo.localhost
# modifier le Caddyfile pour changer le nom de domaine

# la configuration suivante est pour le mmode developpement
services:
  lb:
    image: caddy
    hostname: lb
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
  
# le container memo_db est un container postgresql
# il contient la structure de la base de donnée  et juste un petit jeu de données pour l'exemple
  memo_db:
    image: damiend0cker/memo_db:v.1.0.5
    restart: on-failure
    container_name: memo_db
    volumes:
      - memo_db_data:/var/lib/postgresql/data
    
  


  memo_app:
    image: damiend0cker/memo_svelte:dev
    container_name: front
    hostname: front
    working_dir: /app
    volumes:
    # à modifier selon votre arborescence
      - ../memo-sveltkit:/app  
    restart: on-failure
    ports:
      - 3000:3000
    depends_on:
      - memo_db
    environment:
      DATABASE_URL: postgres://memo:memo@memo_db:5432/memo?sslmode=disable

volumes:
  memo_db_data:



```

## la configuration suivante est pour le mmode production

```yml


# docker-compose -f docker-compose-prod.yml up -d  pour lancer les containers... 

# la configuration suivante est pour le mmode production
services:

  lb:
    image: caddy
    hostname: lb
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
  
# le container memo_db est un container postgresql
# il contient la structure de la base de donnée  et un jeu de données pour l'exemple
  memo_db:
    image: damiend0cker/memo_db:v.1.0.5
    restart: on-failure
    container_name: memo_db
    volumes:
      - memo_db_data:/var/lib/postgresql/data



# une partie du code s'execute coté serveur et une partie coté client
  memo_app:
    image: damiend0cker/memo_svelte:v.2.0.2
    hostname: front
    restart: on-failure
    depends_on:
      - memo_db
    environment:
          DATABASE_URL: postgres://memo:memo@memo_db:5432/memo?sslmode=disable



volumes:
  memo_db_data:


```

![Automated Upload](https://github.com/Damien-Petit-Thomas/memo_db_compose/actions/workflows/container.yml/badge.svg)

![Automated Upload](https://github.com/Damien-Petit-Thomas/memo_db_compose/actions/workflows/ansible.yml/badge.svg)
