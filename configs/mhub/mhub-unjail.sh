#!/usr/bin/env bash

KEY_NAME=validator1;
KEYRING_BACKEND=test;
CHAIN_ID=mhub-test-5;

test -f ~/.config/systemd-mhub.env && source ~/.config/systemd-mhub.env;

MHUB_WALLET_VALOPER_ADDRESS=$(mhub keys show "$KEY_NAME" -a --bech=val --keyring-backend "$KEYRING_BACKEND");

function is_jailed() {
  local jailed=$( \
  mhub \
  --chain-id="$CHAIN_ID" \
  --node=http://localhost:36657 \
  query staking validator "$MHUB_WALLET_VALOPER_ADDRESS" 2>/dev/null | \
  grep "jailed" | \
  awk '{split($0,a,":"); print a[2]}' | \
  xargs);

 echo  "$jailed";
}

function unjail() {
  local res=$( \
  mhub \
  --from="$KEY_NAME" \
  --keyring-backend "$KEYRING_BACKEND" \
  --chain-id="$CHAIN_ID" \
  --node=http://localhost:36657 \
  tx slashing unjail -y 2>/dev/null \
  );

  echo "$res";
}


case $1 in
  jailed)
   is_jailed
   exit
  ;;

  unjail)
    unjail
    exit
  ;;

  *)
    if [[ "$(is_jailed)" == 'true' ]]; then
      unjail
      exit
    fi
  ;;
esac


exit 0 #all was running
