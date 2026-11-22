#!/bin/bash
# Double-click this in Finder (Mac) to play Basement in Brooklyn in your browser.
cd "$(dirname "$0")"
PORT=8765
echo "Starting Basement in Brooklyn on http://127.0.0.1:$PORT ..."
# Open browser after a short delay
(sleep 1; open "http://127.0.0.1:$PORT/index.html") &
# Python 3 ships on modern macOS; fall back to python
if command -v python3 >/dev/null 2>&1; then
  python3 -m http.server "$PORT"
elif command -v python >/dev/null 2>&1; then
  python -m http.server "$PORT"
else
  echo "Python not found. Open Terminal in this folder and run:"
  echo "  npx --yes serve -p $PORT"
  echo "Or drag this whole folder onto https://app.netlify.com/drop"
  read -r _
fi
