#!/bin/bash

# Script to start the admin portal before running tests

echo "=========================================="
echo "Starting Admin Portal"
echo "=========================================="
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ADMIN_PORTAL_DIR="$SCRIPT_DIR/../admin-portal"

# Check if admin-portal directory exists
if [ ! -d "$ADMIN_PORTAL_DIR" ]; then
    echo "❌ Error: admin-portal directory not found at: $ADMIN_PORTAL_DIR"
    echo "Please ensure the admin-portal is in the parent directory."
    exit 1
fi

# Navigate to admin-portal directory
cd "$ADMIN_PORTAL_DIR" || exit 1

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo ""
fi

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo "⚠️  Warning: .env.local not found"
    echo "Creating .env.local with default values..."
    echo "NEXT_PUBLIC_API_BASE_URL=http://localhost:3001/v1" > .env.local
    echo "Please update .env.local with your actual API URL"
    echo ""
fi

echo "🚀 Starting admin portal on http://localhost:3000"
echo "Press Ctrl+C to stop the server"
echo ""

# Start the development server
npm run dev

