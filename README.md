
## `README.md`

# Zsh Copilot

Zsh Copilot is a Zsh plugin that integrates AI-powered command suggestions directly into your terminal. It supports multiple AI backends, including OpenAI, Ollama, Claude, and Google's AI services, allowing you to choose the best assistant for your needs.

## Features

- **AI-Powered Suggestions**: Get intelligent command completions and suggestions as you type.
- **Multiple AI Backends**: Choose from OpenAI, Ollama, Claude, or Google AI services.
- **Configurable Key Bindings**: Assign different key shortcuts to each AI backend for quick access.
- **Context-Aware**: The assistant considers your system information, current directory, and shell environment to provide relevant suggestions.
- **Customizable**: Easily configure settings and add new AI backends.

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/zsh-copilot.git
   ```

2. **Navigate to the Directory**

   ```bash
   cd zsh-copilot
   ```

3. **Update Configuration**

   Edit the configuration file `config/config.zsh` to set your API keys, preferred settings, and key bindings.

## Usage

1. **Source the Plugin in Your `.zshrc`**

   Add the following line to your `.zshrc` file:

   ```zsh
   source /path/to/zsh-copilot/zsh-copilot.plugin.zsh
   ```

   Replace `/path/to/zsh-copilot` with the actual path to where you cloned the repository.

2. **Reload Your Shell**

   ```bash
   source ~/.zshrc
   ```

3. **Activate Zsh Copilot**

   - Start typing a command in your terminal.
   - Press the configured key binding to receive AI suggestions.

## Configuration

All configurations are stored in `config/config.zsh`. Below are the key settings you can customize:

- **Key Bindings**: Map key bindings to AI backends.

  ```zsh
  typeset -A ZSH_COPILOT_KEYS=(
      '^O' "openai"
      '^L' "ollama"
      '^C' "claude"
      '^G' "google"
  )
  ```

  - `^O` represents `Ctrl+O`.
  - Modify the key combinations and backend names as desired.

- **Send Context Information**:

  ```zsh
  : ${ZSH_COPILOT_SEND_CONTEXT:=true}
  ```

  - When set to `true`, the assistant receives additional context about your environment.

- **Enable Debug Logging**:

  ```zsh
  : ${ZSH_COPILOT_DEBUG:=false}
  ```

  - Set to `true` to enable logging for troubleshooting.

- **AI Backend Configurations**:

  - **OpenAI**:

    ```zsh
    : ${OPENAI_API_KEY:='your-openai-api-key'}
    : ${OPENAI_API_URL:='https://api.openai.com'}
    ```

  - **Ollama**:

    ```zsh
    : ${OLLAMA_API_URL:='http://localhost:11434'}
    : ${OLLAMA_MODEL:='llama3'}
    ```

  - **Claude**:

    ```zsh
    : ${CLAUDE_API_KEY:='your-claude-api-key'}
    : ${CLAUDE_API_URL:='https://api.anthropic.com'}
    ```

  - **Google AI Services**:

    ```zsh
    : ${GOOGLE_API_KEY:='your-google-api-key'}
    : ${GOOGLE_API_URL:='https://generativelanguage.googleapis.com'}
    ```

## Supported AI Backends

### OpenAI

- **Requirements**: OpenAI API key.
- **Usage**: Press `Ctrl+O` to get suggestions from OpenAI.

### Ollama

- **Requirements**: Ollama installed and running.
- **Usage**: Press `Ctrl+L` to get suggestions from Ollama.

### Claude

- **Requirements**: Access to Claude's API.
- **Usage**: Press `Ctrl+C` to get suggestions from Claude.

### Google AI Services

- **Requirements**: Access to Google's AI services.
- **Usage**: Press `Ctrl+G` to get suggestions from Google AI.

## Adding New AI Backends

To add a new AI backend:

1. **Create a New Backend Script**: Add a new `.zsh` file in the `ai_backends/` directory.

2. **Implement the Backend Function**: The script should define a `_suggest_ai_backend` function following the pattern of existing backends.

3. **Update Configuration**:

   - Add your API keys and settings to `config/config.zsh`.
   - Map a key binding to your new backend in `ZSH_COPILOT_KEYS`.

## Troubleshooting

- **No Suggestions**: Ensure your API keys are correctly set and that you have network connectivity.
- **Debug Logging**: Set `ZSH_COPILOT_DEBUG=true` to enable logs at `/tmp/zsh-copilot.log`.
- **Dependencies**: Ensure `curl` and `jq` are installed on your system.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.

## Final Remarks

By updating the `README.md` and switching to the GNU GPLv3 license, your project now clearly communicates its features, usage instructions, and licensing terms to users and contributors.

### Reminder

- **API Keys**: Ensure you replace placeholder API keys with your actual keys in `config/config.zsh`. Keep these keys secure and do not commit them to a public repository.
- **Testing**: After making changes, thoroughly test each AI backend to ensure they function as expected.
- **Dependencies**: Make sure all required dependencies (`curl`, `jq`, etc.) are installed on your system.

---

If you need further assistance or have additional questions, feel free to ask!