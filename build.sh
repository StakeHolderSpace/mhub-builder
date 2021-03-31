#!/usr/bin/env sh

TAG=2.0.0

echo Building stakeholder/minter-cmder:dev
docker build --network host -t stakeholder/minter-cmder:dev . -f Dockerfile.dev

echo Building stakeholder/minter-cmder:builder
docker build --network host -t stakeholder/minter-cmder:builder . -f Dockerfile.build

echo Building stakeholder/minter-cmder:${TAG}
docker build --no-cache --network host -t stakeholder/minter-cmder:${TAG} .
