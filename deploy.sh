docker-compose up -d --build

# 불필요한 docker container 삭제
docker volume rm $(docker volume ls -qf dangling=true)

# 불필요한 docker image 삭제
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
docker images -a | sed '1 d' | awk '{print $3}' | xargs -L1 docker rmi -f