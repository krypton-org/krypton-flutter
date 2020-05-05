docker network create krypton-auth-net-test

docker run \
    --detach \
    --name krypton-auth-db-test \
    --network krypton-auth-net-test \
    mongo

docker run \
    --detach \
    --name krypton-auth-test \
    --network krypton-auth-net-test \
    --env MONGODB_URI="mongodb://krypton-auth-db-test:27017/users" \
    --publish 5000:5000 \
    kryptonorg/krypton-auth
