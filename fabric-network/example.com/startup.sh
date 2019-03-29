if [ ! -d "crypto-config" ]; then
    ./generate.sh
  fi

docker-compose up -d