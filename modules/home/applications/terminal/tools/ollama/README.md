# 🤖 Ollama Module for Home-Manager

A comprehensive NixOS/nix-darwin module for running Large Language Models (LLMs) locally using [Ollama](https://ollama.ai).

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Available Commands](#-available-commands)
- [Model Management](#-model-management)
- [Integrations](#-integrations)
- [Troubleshooting](#-troubleshooting)

## ✨ Features

- **🚀 Automatic Service Management**: Systemd user service with auto-start capabilities
- **📦 Declarative Model Management**: Define models in your Nix configuration
- **🎯 Model Presets**: Pre-configured sets of models for different use cases
- **⚡ Hardware Acceleration**: Support for Metal (macOS), CUDA, and ROCm
- **🛠️ Rich CLI Tools**: Interactive chat, code assistant, RAG system, and more
- **🔌 Editor Integrations**: Automatic configuration for Zed, VSCode, and Neovim
- **📊 Resource Management**: CPU and memory limits, garbage collection
- **🔐 Security Hardening**: Systemd sandboxing and security features
- **🌐 CORS Support**: Configure allowed origins for web applications

## 📦 Installation

The module is already included in your configuration. To enable it, add the following to your home configuration:

```nix
{
  applications.terminal.tools.ollama.enable = true;
}
```

## ⚙️ Configuration

### Basic Configuration

```nix
{
  applications.terminal.tools.ollama = {
    enable = true;
    
    # Hardware acceleration (auto-detected for macOS)
    acceleration = "metal";  # Options: "none", "metal", "cuda", "rocm"
    
    # Models to install automatically
    models = [
      "llama3.2"      # Compact 3B model
      "codellama"     # Code generation
      "mistral"       # 7B general model
    ];
    
    # Service configuration
    service = {
      enable = true;
      autoStart = true;  # Start on login
    };
  };
}
```

### Advanced Configuration

```nix
{
  applications.terminal.tools.ollama = {
    enable = true;
    
    # Network configuration
    host = "127.0.0.1";
    port = 11434;
    corsOrigins = [ "http://localhost:3000" ];
    
    # Resource limits
    maxMemory = "16GiB";
    cpuQuota = "400%";  # 4 CPU cores
    
    # Environment variables
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "4";        # Parallel requests
      OLLAMA_MAX_LOADED_MODELS = "2";   # Models in memory
      OLLAMA_KEEP_ALIVE = "10m";        # Model timeout
      OLLAMA_DEBUG = "false";
    };
    
    # Model presets (automatically pulls model sets)
    modelPresets = [
      "general"      # llama3.2, mistral
      "coding"       # codellama, deepseek-coder
      "small"        # phi3, tinyllama
    ];
    
    # Shell aliases
    shellAliases = {
      enable = true;
      aliases = {
        ai = "ollama run llama3.2";
        ai-code = "ollama run codellama";
        ai-chat = "ollama-chat llama3.2";
      };
    };
    
    # Editor integrations
    integrations = {
      zed = true;      # Configure Zed editor
      vscode = false;  # Configure VSCode
      neovim = false;  # Configure Neovim
    };
    
    # Model management
    modelManagement = {
      autoUpdate = false;  # Update models on start
      garbageCollection = {
        enable = true;
        schedule = "weekly";
      };
    };
  };
}
```

## 🚀 Usage

### Starting the Service

The service starts automatically if `autoStart = true`. To manually control it:

```bash
# Start the service
systemctl --user start ollama

# Stop the service
systemctl --user stop ollama

# Restart the service
systemctl --user restart ollama
ollama-restart  # Alias

# Check status
systemctl --user status ollama
ollama-status   # Alias with additional info

# View logs
journalctl --user -u ollama -f
ollama-logs     # Alias
```

### Basic Commands

```bash
# Run a model interactively
ollama run llama3.2

# Use configured aliases
ai "Tell me a joke"
ai-code "Write a Python function to sort a list"

# List installed models
ollama list
ollama-models  # Alias

# Show running models
ollama ps
ollama-ps      # Alias

# Pull a new model
ollama pull llama3.1:70b

# Remove a model
ollama rm llama3.1:70b
```

## 🛠️ Available Commands

### Interactive Tools

#### 🗨️ **ollama-chat** - Interactive Chat Interface
```bash
ollama-chat [model]

# Features:
# - Persistent chat history
# - Model switching with /model command
# - Save conversations
# - Clear screen with /clear
# - Exit with /exit

# Example:
ollama-chat llama3.2
```

#### 💻 **ollama-code** - Code Assistant
```bash
ollama-code [OPTIONS] [PROMPT]

# Options:
-f, --file FILE      # Analyze a file
-l, --language LANG  # Specify language
-r, --review         # Review code
-e, --explain        # Explain code
-o, --optimize       # Suggest optimizations
-t, --test           # Generate tests
-d, --doc            # Generate documentation

# Examples:
ollama-code "Write a binary search in Rust"
ollama-code -f script.py -r  # Review Python file
ollama-code -f app.js -e     # Explain JavaScript
ollama-code -l go "implement a web server"
```

#### 📚 **ollama-rag** - Document Q&A System
```bash
ollama-rag [COMMAND]

# Commands:
index FILE/DIR    # Index documents
query QUESTION    # Query indexed documents
list             # List indexed documents
clear            # Clear indexes

# Examples:
ollama-rag index ~/Documents/manual.pdf
ollama-rag index ~/projects/docs/
ollama-rag query "How do I configure the API?"
```

#### 🎛️ **ollama-model-manager** - Interactive Model Manager
```bash
ollama-model-manager

# Features:
# - List and manage models
# - Install model presets
# - Check disk usage
# - Update all models
# - Interactive menu interface
```

### Utility Commands

#### 📊 **ollama-benchmark** - Model Performance Testing
```bash
ollama-benchmark

# Tests all installed models with a standard prompt
# Shows response time and token generation speed
```

#### 🔄 **ollama-compare** - Compare Model Responses
```bash
ollama-compare "prompt" [model1 model2 ...]

# Example:
ollama-compare "Explain quantum computing" llama3.2 mistral phi3
```

#### 🌐 **ollama-translate** - Translation Helper
```bash
ollama-translate [FROM_LANG] [TO_LANG] TEXT

# Examples:
ollama-translate English Spanish "Hello world"
ollama-translate French German "Bonjour le monde"
```

#### 📝 **ollama-summarize** - Text Summarization
```bash
ollama-summarize [FILE or TEXT]

# Examples:
ollama-summarize article.txt
ollama-summarize "Long text to summarize..."
```

#### 🔌 **ollama-api** - Direct API Client
```bash
ollama-api [COMMAND] [OPTIONS]

# Commands:
generate MODEL PROMPT    # Generate text
chat MODEL MESSAGE       # Chat conversation
embeddings MODEL TEXT    # Generate embeddings
tags                    # List models
health                  # Check API health

# Example:
ollama-api generate llama3.2 "Hello!"
ollama-api health
```

## 📦 Model Management

### Model Presets

The module includes predefined model sets for common use cases:

| Preset | Models | Description |
|--------|--------|-------------|
| `general` | llama3.2, mistral | General purpose chat and text |
| `coding` | codellama, deepseek-coder, codegemma | Code generation and analysis |
| `small` | phi3, tinyllama, gemma2:2b | Resource-efficient models |
| `large` | llama3.1:70b, mixtral:8x7b | Advanced models (high RAM) |
| `multimodal` | llava, bakllava | Text and image processing |
| `specialized` | sqlcoder, medllama2, nous-hermes2 | Domain-specific models |

To use presets:
```nix
{
  applications.terminal.tools.ollama.modelPresets = [ "general" "coding" ];
}
```

### Manual Model Management

```bash
# Pull specific model versions
ollama pull llama3.2:latest
ollama pull codellama:13b
ollama pull mistral:7b-instruct

# Update all models
ollama-update

# Clean cache
ollama-clean
```

## 🔌 Integrations

### Zed Editor

When `integrations.zed = true`, the module automatically configures Zed to use your local Ollama instance:

```json
{
  "assistant": {
    "default_model": {
      "provider": "ollama",
      "model": "llama3.2:latest"
    }
  },
  "language_models": {
    "ollama": {
      "api_url": "http://localhost:11434"
    }
  }
}
```

### API Access

The Ollama API is available at `http://localhost:11434` by default:

```bash
# Check API health
curl http://localhost:11434/api/tags

# Generate text
curl -X POST http://localhost:11434/api/generate \
  -d '{"model": "llama3.2", "prompt": "Hello"}'
```

## 🔧 Troubleshooting

### Service Not Starting

```bash
# Check service status
systemctl --user status ollama

# View detailed logs
journalctl --user -u ollama -xe

# Verify port availability
lsof -i :11434
```

### Model Download Issues

```bash
# Check available disk space
df -h ~/.ollama

# Clean unused models
ollama list | grep -v NAME | awk '{print $1}' | xargs -I {} ollama rm {}

# Retry model pull with verbose output
OLLAMA_DEBUG=true ollama pull llama3.2
```

### Performance Issues

1. **Adjust parallel requests**:
   ```nix
   environmentVariables.OLLAMA_NUM_PARALLEL = "1";
   ```

2. **Limit loaded models**:
   ```nix
   environmentVariables.OLLAMA_MAX_LOADED_MODELS = "1";
   ```

3. **Set memory limits**:
   ```nix
   maxMemory = "8GiB";
   ```

4. **Reduce model timeout**:
   ```nix
   environmentVariables.OLLAMA_KEEP_ALIVE = "1m";
   ```

### GPU Acceleration Issues

For macOS Metal acceleration:
```bash
# Verify Metal is enabled
OLLAMA_DEBUG=true ollama run llama3.2 --verbose

# Check GPU usage
sudo powermetrics --samplers gpu_power -i1000 -n1
```

## 📚 Additional Resources

- [Ollama Official Documentation](https://github.com/ollama/ollama)
- [Ollama Model Library](https://ollama.ai/library)
- [Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)

## 🤝 Contributing

To add new features or models to this module:

1. Edit the appropriate file in `modules/home/applications/terminal/tools/ollama/`
2. Test your changes: `darwin-rebuild check --flake .`
3. Apply changes: `darwin-rebuild switch --flake .`

## 📄 License

This module is part of the system configuration and follows the same license as the parent project.