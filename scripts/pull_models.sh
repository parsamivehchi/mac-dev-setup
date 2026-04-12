#!/usr/bin/env bash
set -euo pipefail

# Pull recommended Ollama models for LLM development.
# Skips models that are already downloaded.

models=(
    "qwen3-coder:latest"
    "qwen2.5-coder:14b"
    "deepseek-r1:14b"
    "llama3.2:3b"
    "nomic-embed-text"
)

if ! command -v ollama &>/dev/null; then
    echo "  Ollama is not installed — skipping model pulls."
    exit 0
fi

# Start Ollama in the background if it is not already running
if ! pgrep -x ollama &>/dev/null; then
    echo "  Starting Ollama server in the background..."
    ollama serve &>/dev/null &
    OLLAMA_PID=$!
    sleep 3
    STARTED_OLLAMA=true
else
    STARTED_OLLAMA=false
fi

for model in "${models[@]}"; do
    # Check if model is already pulled by listing local models
    if ollama list 2>/dev/null | grep -q "^${model}"; then
        echo -e "  \033[1;33m→\033[0m ${model} (already pulled, skipping)"
    else
        echo -e "  Pulling ${model}..."
        if ollama pull "$model"; then
            echo -e "  \033[1;32m✓\033[0m ${model} pulled"
        else
            echo -e "  \033[1;31m✗\033[0m Failed to pull ${model}"
        fi
    fi
done

# Stop Ollama if we started it
if [[ "$STARTED_OLLAMA" == "true" ]]; then
    kill "$OLLAMA_PID" 2>/dev/null || true
fi
