#!/bin/bash
# Startup script for BlueFarm on macOS (React + Flutter)

echo "🌊 Starting BlueFarm Backend & Frontend..."

# Kill any existing process on ports 3000 and 4000
lsof -ti:4000 | xargs kill -9 2>/dev/null
lsof -ti:3000 | xargs kill -9 2>/dev/null

# 1. Start the React Frontend in the background
echo "Starting React App on port 4000..."
cd react_frontend
PORT=4000 npm start &
REACT_PID=$!

# Wait for React to spin up
sleep 5

# 2. Go back to root and start Flutter Web
cd ..
echo "Starting Flutter Wrapper on port 3000..."
flutter run -d chrome --web-port=3000

# Cleanup when Flutter closes
kill $REACT_PID
echo "BlueFarm closed."
