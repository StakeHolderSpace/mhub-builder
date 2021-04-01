# Docker Minter Hub

## [Minter Hub](https://github.com/MinterTeam/minter-hub)

## 0 build Docker images
```bash
docker build --rm --network=host -t stakeholder/dockerfile-gox -f gox.Dockerfile .
docker build --rm --network=host -t stakeholder/minter-hub:builder -f builder.Dockerfile .
docker build --network=host  -t stakeholder/minter-hub .
```

## 1 Copy binaries to host
```bash
docker run  --rm \
-v $(pwd)/mhub:/mhub/.mhub:rw \
-v $(pwd)/build:/mhub/build:rw \
stakeholder/minter-hub:latest bash -c "cd /mhub/bin/ ; \
zip -r /mhub/build/linux/mhub_$(mhub version)_linux.zip *; \
cd /mhub/build/linux/ && sha256sum -b * > mhub_$(mhub version)_SHA256SUMS" 
```
