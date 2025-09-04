#!/bin/bash

# Restart script for mighty-dawn API Service

echo "=== Restarting mighty-dawn API Service ==="

# Stop the service if running
if systemctl is-active --quiet mighty-dawn-api.service; then
    echo "Stopping mighty-dawn service..."
    sudo systemctl stop mighty-dawn-api.service

    # Wait a bit for graceful shutdown
    sleep 3

    # Check if it's actually stopped
    if systemctl is-active --quiet mighty-dawn-api.service; then
        echo "Service still running, waiting longer..."
        sleep 5
    fi
else
    echo "Service was not running"
fi

# Start the service
echo "Starting mighty-dawn service..."
sudo systemctl start mighty-dawn-api.service

# Wait for startup
sleep 5

# Verify the service is running
RETRY_COUNT=0
MAX_RETRIES=6

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if systemctl is-active --quiet mighty-dawn-api.service; then
        echo "✅ Service restarted successfully"
        echo
        echo "=== Service Status ==="
        sudo systemctl status mighty-dawn-api.service --no-pager -l
        echo
        echo "=== Recent Logs ==="
        sudo journalctl -u mighty-dawn-api.service -n 10 --no-pager
        exit 0
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Service not ready yet, waiting... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 5
done

# If we reach here, the service failed to start
echo "❌ Service failed to start after restart"
echo
echo "=== Service Status ==="
sudo systemctl status mighty-dawn-api.service --no-pager -l
echo
echo "=== Recent Error Logs ==="
sudo journalctl -u mighty-dawn-api.service -n 20 --no-pager
exit 1