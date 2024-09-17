# Zsh Copilot

Zsh Copilot is an AI-powered command-line assistant that helps you with shell commands using various AI models.

## Features

- Provides intelligent command suggestions and completions
- Supports multiple AI providers: OpenAI, Ollama, Google Gemini, and Mistral
- Customizable key binding for triggering suggestions
- Option to include system context in prompts
- Debug logging for troubleshooting
- API key validation for supported providers

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/zsh-copilot.git ~/.zsh/zsh-copilot
   ```

2. Add the following to your `~/.zshrc`:
   ```zsh
   source ~/.zsh/zsh-copilot/zsh-copilot.zsh
   ```

3. Reload your Zsh configuration or restart your terminal:
   ```
   source ~/.zshrc
   ```

## Configuration

### API Keys

Set your API keys in your `~/.zshrc` or `~/.zshenv`:

```zsh
export OPENAI_API_KEY="your_openai_api_key_here"
export GOOGLE_API_KEY="your_google_api_key_here"
export MISTRAL_API_KEY="your_mistral_api_key_here"
```

### API Key Validation

Zsh Copilot includes API key validation for supported providers:

- The plugin checks the validity of your API keys when it's first loaded.
- If a key is missing or appears to be invalid, you'll see a warning message.
- This check is performed only once per session to avoid unnecessary API calls.

If you see a warning about your API key:
1. Ensure that you've correctly set the API key in your `~/.zshrc` or `~/.zshenv`.
2. Check that your API key is valid and has the necessary permissions.
3. If the issue persists, there might be a connection problem to the API service.

You can manually trigger a re-check of your API keys by reloading your Zsh configuration:
```
source ~/.zshrc
```

### Plugin Settings

The plugin comes with default settings, but you can customize them if needed. These settings are defined in the `zsh-copilot-config.zsh` file. If you want to change them, you can do so by editing this file directly or by overriding them in your `~/.zshrc`:

```zsh
# Key binding to trigger Zsh Copilot (default: ^z)
export ZSH_COPILOT_KEY='^z'

# Whether to send context information to the AI model (default: true)
export ZSH_COPILOT_SEND_CONTEXT=true

# AI provider to use: "openai", "ollama", "gemini", or "mistral" (default: openai)
export ZSH_COPILOT_LLM_PROVIDER="openai"

# OpenAI model to use (default: gpt-4)
export ZSH_COPILOT_OPENAI_MODEL="gpt-4"

# Ollama model to use (default: llama3.1:8b)
export ZSH_COPILOT_OLLAMA_MODEL="llama3.1:8b"

# Google Gemini model to use (default: gemini-1.5-pro)
export ZSH_COPILOT_GEMINI_MODEL="gemini-1.5-pro"

# Mistral model to use (default: mistral-large-latest)
export ZSH_COPILOT_MISTRAL_MODEL="mistral-large-latest"

# Enable debug logging (default: false)
export ZSH_COPILOT_DEBUG=false

source ~/.zsh/zsh-copilot/zsh-copilot.zsh
```

## Usage

1. Type a partial command or describe what you want to do.
2. Press the configured key (default: Ctrl+Z) to trigger Zsh Copilot.
3. Zsh Copilot will either complete your command or suggest a new one.

Example:
```
$ list files in current directory<Ctrl+Z>
$ ls -la  # ls is the command to list files and directories
```

## Troubleshooting

If you encounter any issues:

1. Ensure your API keys are correctly set and valid.
2. Check that all required files are in the correct location.
3. Enable debug logging by setting `ZSH_COPILOT_DEBUG=true` in your `~/.zshrc`.
4. Check the log file at `/tmp/zsh-copilot.log` for error messages.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Changelog

### v1.0.0 (2023-09-17)
- Initial release
- Support for OpenAI and Ollama as AI providers
- Customizable key binding
- Context-aware suggestions
- Debug logging
- Personalized "Thinking" messages based on AI provider

### v1.0.1 (2023-09-17)
- Fixed issue with repeated OpenAI API key warnings
- Improved README with detailed installation and configuration instructions
- Added changelog to README

### v1.0.2 (2023-09-17)
- Added API key validation feature
- Updated configuration section in README to clarify plugin settings
- Improved troubleshooting section with API key validation information

### v1.0.3 (2023-09-17)
- Fixed "command not found: zsh_copilot_debug" error
- Reorganized code to ensure debug function is defined before use
- Improved debug logging across all plugin files

### v1.0.4 (2023-09-17)
- Removed comments from Ollama suggestions
- Improved handling of AI suggestions in the main script
- Updated `get_ai_suggestion` function to clean responses
- Enhanced debug logging for better troubleshooting

### v1.1.0 (2023-09-18)
- Added support for Google Gemini API
- Implemented Mistral API integration
- Updated configuration options to include new AI providers
- Enhanced API key validation to support all providers
- Updated README with new provider information and configuration options
- Improved error handling and debug logging for new providers