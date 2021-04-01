# Docker Minter Hub
## 0 build Docker images
```bash
docker build --rm --network=host -t stakeholder/dockerfile-gox -f gox.Dockerfile .
docker build --rm --network=host -t stakeholder/minter-hub:builder -f builder.Dockerfile .
docker build --network=host  -t stakeholder/minter-hub .
```

## 0.1 Copy binaries to host
```bash
docker run  --rm \
-v $(pwd)/mhub:/mhub/.mhub:rw \
-v $(pwd)/build:/mhub/build:rw \
stakeholder/minter-hub:latest cp -a /mhub/bin/. /mhub/build/linux/
```


## 1 Run and Sync Minter Hub Node
```bash
docker run  --rm -d \
-p 127.0.0.1:36656:36656 \
-p 127.0.0.1:26657:26657 \
-p 127.0.0.1:1317:1317 \
-p 127.0.0.1:1090:1090 \
-p 127.0.0.1:9090:9090 \
-v $(pwd)/mhub:/mhub/.mhub:rw \
-v /etc/hostname:/etc/hostname:ro \
--ulimit nofile=10000:10000 \
--log-driver journald \
--name minter-hub \
\
stakeholder/minter-hub:latest mhub start \
--home /mhub/.mhub \
--moniker StakeHolder-Node \
--p2p.persistent_peers="bb75bf42dd14f55bb6528e7588d8e63cd2db2a44@46.101.215.17:36656"

#OR
docker-compose up -d
```


## 2 Generate Hub account
```bash
docker run  --rm -it \
-v $(pwd)/mhub:/mhub/.mhub:rw \
-v /etc/hostname:/etc/hostname:ro \
stakeholder/minter-hub:latest mhub keys add validator1 --home /mhub/.mhub --keyring-backend test 

#>>>>
- name: validator1
  type: local
  address: hub1xjuc8rm6w53xkfyucn4yrkequc0rcuer8zgyx6
  pubkey: hubpub1addwnpepq008c0sgd6kj5ee3fuvy6emq5qqlkjfglrxy7ctzvdmwlypcpps6sqe4dyj
  mnemonic: ""
  threshold: 0
  pubkeys: []


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

fortune exit regular old organ snake pencil farm normal ecology limb improve raise mansion joy prize broom dune address panda observe special tank rack
```

Helpful commands:
```bash
VALIDATOR_ADDRESS=$(mhub keys show validator1 -a --keyring-backend test)

docker run  --rm -it \
-v $(pwd)/mhub:/mhub/.mhub:rw \
-v /etc/hostname:/etc/hostname:ro \
stakeholder/minter-hub:latest mhub keys show validator1 -a --home /mhub/.mhub --keyring-backend test

docker run  --rm -it \
-v $(pwd)/mhub:/mhub/.mhub:rw \
-v /etc/hostname:/etc/hostname:ro \
stakeholder/minter-hub:latest mhub keys list --home /mhub/.mhub --keyring-backend test

docker run  --rm -it \
--network=host \
-v $(pwd)/mhub:/mhub/.mhub:rw \
stakeholder/minter-hub:latest mhub query bank balances hub1da5v33vw2wzsfch0kkzjvxmc59a0r4als24cl6
```

## 3 Create Hub validator
### 3.1 Get validator pubkey
```bash
docker run  --rm -it \
-v $(pwd)/mhub:/mhub/.mhub:rw \
-v /etc/hostname:/etc/hostname:ro \
stakeholder/minter-hub:latest mhub tendermint show-validator --home /mhub/.mhub 

#>>>
cosmosvalconspub1zcjduepqz4ea4ne8jlzny84cnlm2k0gy9jwmus7kjcjpdwzvskftuanwlyksyhvntn
```
###3.2 Register Hub validator
```bash
docker run  --rm -it \
--network=host \
-v $(pwd)/mhub:/mhub/.mhub:rw \
\
stakeholder/minter-hub:latest sh -c 'mhub tx staking create-validator \
--amount=10hub \
--pubkey=$(mhub tendermint show-validator --home /mhub/.mhub) \
--moniker StakeHolder \
--commission-rate="0.1" \
--commission-max-rate="1" \
--commission-max-change-rate="0.1" \
--min-self-delegation="1" \
--from=validator1 \
--keyring-backend test \
--home /mhub/.mhub \
--node tcp://127.0.0.1:26657'

#>>>

```
 
## 4 Generate Minter & Ethereum keys
```bash 
docker run  --rm -it \
-v $(pwd)/mhub:/mhub/.mhub:rw \
stakeholder/minter-hub:latest  mhub-keys-generator --home /mhub/.mhub 

#>>>
Ethereum private key: c6b9b61db8d5ce832ac37abee7b63cb853ddf739e65219f84b29dcea04f264a2
Ethereum address: 0xc950BE987A599C3E30AC24006a4980BF5DA225Fb

Minter mnemonic: ankle taste coach race praise skirt palm sport hamster exhibit furnace vendor
Minter address: Mx0a7884b122fa52cd32495523a1691fe1e22c8bdf

```
[Request some test ETH to your generated address](https://faucet.ropsten.be/)


## 5 Register Ethereum keys
```bash
docker run  --rm -it \
--network=host \
-v $(pwd)/mhub:/mhub/.mhub:rw \
\
stakeholder/minter-hub:latest register-peggy-delegate-keys \
--cosmos-phrase="evidence castle provide embark model shop solution pioneer sponsor chalk couch cage stable blade aunt stand start sing glad mechanic ceiling kingdom stay fire" \
--validator-phrase="evidence castle provide embark model shop solution pioneer sponsor chalk couch cage stable blade aunt stand start sing glad mechanic ceiling kingdom stay fire" \
--ethereum-key="2b84acefc6f30c0f2cffd0a72bdeb2d4f0475985e34ce8830fcbcebd56aaddaa" \
--cosmos-rpc="http://127.0.0.1:1317" \
--fees=hub
```
