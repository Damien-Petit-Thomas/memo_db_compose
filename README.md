# fichiers de démarage de l'application

pour executer l'application

`docker-compose -f docker-compose-prod.yml up -d` ou
en developpemnent : ( bien spécifier les chemins pour les  points de montages des volumes ) 
`docker-compose -f docker-compose-dev.yml up -d`

par défaut l'application est accessible en local sur memo.localhost:80 et l'api sur api.localhost:80
modifier le fichier Caddyfile pour changer le nom de domaine et le port d'écoute
pour un déploiement en production sur serveur distant : documentation en cours

## docker-comopose : la configuration suivante est pour le mmode developpement

```yml


services:


  lb:
    image: caddy
    hostname: lb
    restart: on-failure
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile

  memo_db:
    restart: on-failure
    image: damiend0cker/memo_db
    container_name: memo_db
    volumes:
      - memo_db_data:/var/lib/postgresql/data
    restart: always
      
# le container memo_back est un container NodeJs 
  memo_back:
    restart: on-failure
    image: damiend0cker/memo_back:dev
    container_name: memo_back
    WORKDIR: /app
    VOLUME:
    # à modifier selon votre arborescence
      - .:/app

    environment:
      DATABASE_URL: postgres://memo:memo@memo_db:5432/memo?sslmode=disable
    depends_on:
      - memo_db
      
# le container memo_svelte est un container sveltkit  
  memo_svelte:
    restart: on-failure
    image: damiend0cker/memo_svelte:dev
    container_name: front
    WORKDIR: /app
    VOLUME:
    # à modifier selon votre arborescence
      - .:/app  
    restart: always
    depends_on:
      - memo_back
      - memo_db

volumes:
  memo_db_data:

```

## la configuration suivante est pour le mmode production

```yml


services:
   lb:
    image: caddy
    hostname: lb
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
  

# il contient la structure de la base de donnée  et juste un petit jeu de données pour l'exemple
  memo_db:
    image: damiend0cker/memo_db
    container_name: memo_db
    volumes:
      - memo_db_data:/var/lib/postgresql/data
    restart: on-failure

  
      
# le container memo_back est un container NodeJs 
  memo_back:
    image: damiend0cker/memo_back:dev
    container_name: memo_back
    restart: always
    WORKDIR: /app
    environment:
      DATABASE_URL: postgres://memo:memo@memo_db:5432/memo?sslmode=disable
    depends_on:
      - memo_db
      
# une partie du code s'execute coté serveur et une partie coté client
  memo_svelte:
    image: damiend0cker/memo_svelte
    container_name: front
    WORKDIR: /app
    restart: always
    depends_on:
      - memo_back
      - memo_db
    ports:
      - 3000:5173

volumes:
  memo_db_data:

```

![Automated Upload](https://github.com/Damien-Petit-Thomas/memo_db_compose/actions/workflows/container.yml/badge.svg)

![Automated Upload](https://github.com/Damien-Petit-Thomas/memo_db_compose/actions/workflows/ansible.yml/badge.svg)
