# fichiers de démarage de l'application


pour executer l'application 

`docker-compose -f docker-compose-prod.yml up -d` ou 
en developpemnent : bien spécifier les chemins pour les  points de montages des volumes dans le dockerfile
`docker-compose -f docker-compose-dev.yml up -d`


```yml

# docker-compose up -d  pour lancer les containers... l'application est accessible 127.0.0.1

# le server apache permet de faire la resolution dns des nom des containers pour les requetes http vers le back 
# la configuration suivante est pour le mmode developpement
services:
  proxy:
    image: damiend0cker/hattpdproxy
    container_name: proxy
    ports:
      - 80:80

# le container memo_db est un container postgresql
# il contient la structure de la base de donnée  et juste un petit jeu de données pour l'exemple
  memo_db:
    image: damiend0cker/memo_db
    container_name: memo_db
    volumes:
      - memo_db_data:/var/lib/postgresql/data
    restart: always
    ports:
      - 5433:5432
    depends_on:
      - proxy
      
# le container memo_back est un container NodeJs 
  memo_back:
    image: damiend0cker/memo_back:dev
    container_name: memo_back
    restart: always
    WORKDIR: /app
    VOLUME:
    # à modifier selon votre arborescence
      - .:/app
    ports:
      - 3001:3001
    environment:
      DATABASE_URL: postgres://memo:memo@memo_db:5432/memo?sslmode=disable
    depends_on:
      - memo_db
      
# le container memo_svelte est un container sveltkit  il contient le front de l'application 
# une partie du code s'execute coté serveur et une partie coté client
  memo_svelte:
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
    ports:
      - 3000:5173

volumes:
  memo_db_data:

```

```yml

# docker-compose up -d  pour lancer les containers... l'application est accessible 127.0.0.1

# le server apache permet de faire la resolution dns des nom des containers pour les requetes http vers le back 
# la configuration suivante est pour le mmode developpement
services:
  proxy:
    image: damiend0cker/hattpdproxy
    container_name: proxy
    ports:
      - 80:80

# le container memo_db est un container postgresql
# il contient la structure de la base de donnée  et juste un petit jeu de données pour l'exemple
  memo_db:
    image: damiend0cker/memo_db
    container_name: memo_db
    volumes:
      - memo_db_data:/var/lib/postgresql/data
    restart: always
    ports:
      - 5433:5432
    depends_on:
      - proxy
      
# le container memo_back est un container NodeJs 
  memo_back:
    image: damiend0cker/memo_back:dev
    container_name: memo_back
    restart: always
    WORKDIR: /app
    VOLUME:
    # à modifier selon votre arborescence
      - .:/app
    ports:
      - 3001:3001
    environment:
      DATABASE_URL: postgres://memo:memo@memo_db:5432/memo?sslmode=disable
    depends_on:
      - memo_db
      
# le container memo_svelte est un container sveltkit  il contient le front de l'application 
# une partie du code s'execute coté serveur et une partie coté client
  memo_svelte:
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
    ports:
      - 3000:5173

volumes:
  memo_db_data:

```


![Automated Upload](https://github.com/Damien-Petit-Thomas/memo_db_compose/actions/workflows/container.yml/badge.svg)



![Automated Upload](https://github.com/Damien-Petit-Thomas/memo_db_compose/actions/workflows/ansible.yml/badge.svg)