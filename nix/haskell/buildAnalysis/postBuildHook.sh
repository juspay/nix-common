if [ -f server.pid ]; then
  echo "Extracting endpoints..."
  python3 @endpointsExtract@ --output-path $juspayMetadata/@packageName@/endpoints.json || {
    echo "Failed to extract endpoints"
    exit 1
  }
  echo "endpoints extraction - output saved to $juspayMetadata/@packageName@/endpoints.json"

  echo "Extracting environment data..."
  python3 @envExtract@ --output-path $juspayMetadata/@packageName@/env.json || {
    echo "Failed to extract env data"
    exit 1
  }
  echo "env extraction - output saved to $juspayMetadata/@packageName@/env.json"
  
  echo "Extracting service config keys ..."
  python3 @getconfigkey@ --output-path $juspayMetadata/@packageName@/service_configs.json || {
    echo "Failed to extract service Config keys"
    exit 1
  }
  echo "Service config keys has been extracted - output saved to $juspayMetadata/@packageName@"

  echo "Running fdep_merge..."
  python3 @fdep_merge@ --output-path $juspayMetadata/@packageName@/fdep_data.zip || {
    echo "Failed to create fdep_data.zip"
    exit 1
  }

  echo "Creating fdep zip..."
  python3 @tmpzip@ --output-path $juspayMetadata/@packageName@/fdep.zip || {
    echo "Failed to create fdep.zip"
    exit 1
  }
  echo "fdep output zipping complete - output saved to $juspayMetadata/@packageName@"

  # Server cleanup is handled by the trap
  kill $(cat server.pid) 2>/dev/null || true
fi
