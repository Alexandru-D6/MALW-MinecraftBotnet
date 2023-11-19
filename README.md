# MALW-MinecraftBotnet

Intruction:

    *** Docker initialization ***

        + Useful commands for dockder
    - docker ps -a (Show running containers)
    - docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-id>

        + Botnet API deploy (every time you want to udpate the docker image)
    - 'cd ./API'
    - 'docker build -t botnet-api .'
    - 'docker stop botnet-api' (optional)
    - 'docker rm botnet-api' (optional)
    - 'docker run --name botnet-api -p 5000:5000 -d botnet-api'
    - 'docker start/stop botnet-api'