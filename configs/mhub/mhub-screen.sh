#!/usr/bin/env bash
# !!! also can be started from cron and on startup !!!

LOG="/var/log/mhub-screen.log"

screen -wipe mhub >/dev/null

function stop_mhub() {
  # We have checked for the mhub process, but maybe there is a screen with dead mhub
  screens=$(screen -ls mhub | grep -Po "\K[0-9]+(?=\.mhub)")
  if [[ ! -z $screens ]]; then
    echo "Quiting previous screen"
    for pid in $screens; do
      screen -S $pid.mhub -X quit
    done
    return 0
  fi
  return 1
}

function make_mhub() {
  screen -S mhub -X screen -t "MHUB-NODE" sudo journalctl -u mhub-node.service -f
  screen -S mhub -X screen -t "MINTER-NODE" sudo journalctl -u minter-node.service -f
  screen -S mhub -X screen -t "ETH-NODE" sudo journalctl -u eth-node.service -f
  screen -S mhub -X screen -t "MINTER-CONNECTOR" sudo journalctl -u mhub-minter-connector.service -f
  screen -S mhub -X screen -t "ETH-CONNECTOR" sudo journalctl -u mhub-eth-connector.service -f
  screen -S mhub -X screen -t "ORACLE" sudo journalctl -u mhub-oracle.service -f
  screen -S mhub -X screen -t "BASH" bash
}

function restart_mhub() {
  stop_mhub && sleep 0.5

  echo "Starting new mhub screen session"
  screen -dm -S mhub

  for i in {1..25}; do
    sleep 0.2 #it needs some time? it happens that you'll have "No screen session found" without sleep
    session_count=$(screen -ls mhub | grep -c mhub)
    [[ $session_count -gt 0 ]] && break
    [[ $i == 25 ]] && echo -e "${RED}screen mhub not found in 25 iterations, check logs and maybe flash drive speed${NOCOLOR}"
  done

  make_mhub && sleep 0.5

  # close bash window #0
  screen -S mhub -p bash -X stuff 'exit\n'

  return 0
}

function start_mhub() {
  # As we have several processes in screen need to check for actual mhub, not just for screen
  running=$(pgrep -cf '/mhub run$')
  if [[ $running -eq 0 ]]; then
    screen -ls mhub >/dev/null && echo "Screen is running but mhub is not, restarting"
    restart_mhub
    return
  fi
  # check if mhub is alive by checking its log
  local log_ts
  log_ts=$(stat --printf %Y $LOG 2>/dev/null) || log_ts=0
  local now_ts
  now_ts=$(date +%s) || now_ts=0
  if [[ $log_ts -lt $((now_ts - 180)) ]]; then
    echo "mhub is dead, restarting"
    restart_mhub
    return
  fi
  return 0
}

function log_mhub() { # log_window
  local log="/tmp/mhub$1.log"
  [[ -f $log ]] && rm $log
  screen -S mhub -X at $1 hardcopy $log &&
    cat $log
  return
}

case $1 in
  start)
    start_mhub
    exit
    ;;

  dontattach)
    # prevent mhub start from CRON during boot process
    upt=$(cat /proc/uptime | awk '{print int($1)}')
    [[ $upt -lt 300 ]] && echo "Too early" && exit 0
    start_mhub
    exit
    ;;

  restart)
    restart_mhub
    exit
    ;;

  stop)
    stop_mhub
    exit
    ;;

  log)
    tail -n 20 $LOG
    exit
    ;;

  log1)
    log_mhub 1
    exit
    ;;
  log2)
    log_mhub 2
    exit
    ;;
  layout)
    open_layout_mhub
    exit
    ;;

  *)
    start_mhub || exit
    screen -S mhub -x >/dev/null # attach to screen
    if [[ $? -ne 0 ]]; then
      echo "Restarting mhub"
      restart_mhub
      screen -S mhub -x >/dev/null # attach to screen again
      exit
    fi
    ;;
esac

exit 0 #all was running
