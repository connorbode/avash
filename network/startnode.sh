#!/bin/bash
set -e

DATA_DIR="$(pwd)"
CTNR_DIR="/data"

# Node name
NAME=""

# Required flag defaults
H_PORT="9650"
S_PORT="9651"

# Process flags
FLAGS=""
for arg in "$@"
do
    case "$arg" in
        --name=*)
            NAME="${arg#*=}"
            ;;
        --assertions-enabled=*|\
		--tx-fee=*|\
		--network-id=*|\
        --public-ip=*|\
        --dynamic-update-duration=*|\
        --dynamic-public-ip=*|\
		--xput-server-port=*|\
        --xput-server-enabled=*|\
		--signature-verification-enabled=*|\
        --api-admin-enabled=*|\
		--api-ipcs-enabled=*|\
        --api-keystore-enabled=*|\
        --api-metrics-enabled=*|\
		--http-tls-enabled=*|\
		--http-tls-cert-file=*|\
		--http-tls-key-file=*|\
		--bootstrap-ips=*|\
		--bootstrap-ids=*|\
		--db-enabled=*|\
		--log-level=*|\
		--benchlist-duration=*|\
		--benchlist-fail-threshold=*|\
		--consensus-gossip-frequency=*|\
		--benchlist-min-failing-duration=*|\
		--benchlist-peer-summary-enabled=*|\
		--version=*|\
		--snow-avalanche-batch-size=*|\
		--snow-avalanche-num-parents=*|\
		--snow-sample-size=*|\
		--snow-quorum-size=*|\
		--snow-virtuous-commit-threshold=*|\
		--snow-rogue-commit-threshold=*|\
        --uptime-requirement=*|\
		--min-delegator-stake=*|\
		--consensus-shutdown-timeout=*|\
		--min-delegation-fee=*|\
		--min-validator-stake=*|\
		--max-stake-duration=*|\
		--max-validator-stake=*|\
		--snow-concurrent-repolls=*|\
		--stake-minting-period=*|\
		--creation-tx-fee=*|\
		--max-non-staker-pending-msgs=*|\
		--network-initial-timeout=*|\
		--network-minimum-timeout=*|\
		--network-maximum-timeout=*|\
		--network-health-max-time-since-no-requests=*|\
		--network-health-max-send-fail-rate=*|\
		--bootstrap-retry-max-attempts=*|\
		--bootstrap-retry-enabled=*|\
		--health-check-averager-halflife=*|\
		--health-check-frequency=*|\
		--router-health-max-outstanding-requests=*|\
		--router-health-max-drop-rate=*|\
		--restart-on-disconnected=*|\
		--disconnected-check-frequency=*|\
		--disconnected-restart-timeout=*|\
        --p2p-tls-enabled=*|\
		--staking-enabled=*|\
		--staking-disabled-weight=*|\
		--staking-tls-key-file=*|\
		--staking-tls-cert-file=*)
            FLAGS+="${arg} "
            ;;
		--api-auth-required=*|\
		--api-auth-password=*|\
        --min-stake-duration=*|\
        --whitelisted-subnets=*|\
        --api-health-enabled=*|\
        --config-file=*|\
        --api-info-enabled=*|\
        --conn-meter-max-conns=*|\
        --conn-meter-reset-duration=*|\
        --ipcs-chain-ids=*|\
        --ipcs-path=*|\
        --log-display-level=*|\
        --log-display-highlight=*|\
        --fd-limit=*|\
        --http-host=*|\
        --db-dir=*|\
        --log-dir=*|\
        --plugin-dir=*)
            FLAGS+="${arg%=*}=$CTNR_DIR/${arg#*=} "
            ;;
        --data-dir=*)
            DATA_DIR+="/${arg#*=}"
            ;;
        --http-port=*)
            H_PORT="${arg#*=}"
            ;;
        --staking-port=*)
            S_PORT="${arg#*=}"
            ;;
        *)
            echo
            echo "ERROR: Unsupported flag '${arg%%=*}'"
            echo
            exit 1
            ;;
    esac
done
FLAGS+="--http-port=${H_PORT} "
FLAGS+="--staking-port=${S_PORT} "

if [ -z $NAME ]; then
    echo
    echo "ERROR: Missing node name argument (--name=[node name] required)"
    echo
    exit 1
fi

# Build and run Docker image as daemon
AVALANCHE_COMMIT="$(git --git-dir="./avalanchego/.git" rev-parse --short HEAD)"
docker_image="$(docker images -q avalanchego-$AVALANCHE_COMMIT:latest 2> /dev/null)"
if [ -z $docker_image ]; then
    ./avalanchego/scripts/build_image.sh
fi
mkdir -p $DATA_DIR
docker run -d --name $NAME \
    -v $DATA_DIR:$CTNR_DIR \
    -p $H_PORT:$H_PORT \
    -p $S_PORT:$S_PORT \
    avalanchego-$AVALANCHE_COMMIT \
    /avalanchego/build/avalanche $FLAGS
