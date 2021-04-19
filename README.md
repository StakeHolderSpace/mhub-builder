# Docker Minter Hub

## [Minter Hub](https://github.com/MinterTeam/minter-hub)

## 0 build Docker images
```bash
docker build --rm --network=host -t stakeholder/dockerfile-gox -f gox.Dockerfile .
docker build --rm --network=host -t stakeholder/minter-hub:builder -f builder.Dockerfile .
docker build --network=host  -t stakeholder/minter-hub .

sudo docker rmi $(docker images -qa -f 'dangling=true')
```

## 1 Copy binaries to host
```bash
docker run  --rm -it \
-v $(pwd)/mhub:/mhub/.mhub:rw \
-v $(pwd)/build:/mhub/build:rw \
stakeholder/minter-hub:latest bash -c "cd /mhub/bin/ ; \
zip -r /mhub/build/linux/mhub_linux.zip *; \
cd /mhub/build/linux/ && sha256sum -b * > mhub_SHA256SUMS" 
```
