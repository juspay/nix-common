# Create cleanup function
cleanup() {
  if [ -f server.pid ]; then
    echo "Stopping fdep server..."
    kill $(cat server.pid) 2>/dev/null || true
    rm -f server.pid
  fi
  rm -f fdep_port
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

echo "Running fdep server..."
python3 @server@ &
echo $! > server.pid

# Wait for port file with timeout
TIMEOUT=30
COUNTER=0
while [ ! -f fdep_port ]; do
  if [ $COUNTER -ge $TIMEOUT ]; then
    echo "Timeout waiting for fdep server to start"
    exit 1
  fi
  sleep 1
  COUNTER=$((COUNTER + 1))
done

if [ ! -f fdep_port ]; then
  echo "Failed to create fdep_port file"
  exit 1
fi

export SERVER_PORT=$(cat fdep_port)
if [ -z "$SERVER_PORT" ]; then
  echo "Failed to get valid server port"
  exit 1
fi

export NIX_BUILD_API_CONTRACT=True
