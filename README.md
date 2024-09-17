# Zsh Copilot / Zsh Copilot

[English Version](#english-version) | [Version Française](#version-française)

---

## English Version

[Go to French Version](#version-française)

# Zsh Copilot

Zsh Copilot is an AI-powered command-line assistant that helps you with shell commands using various cutting-edge AI models.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Installing Dependencies](#installing-dependencies)
  - [Installing Zsh Copilot](#installing-zsh-copilot)
- [Configuration](#configuration)
  - [API Keys](#api-keys)
  - [API Key Validation](#api-key-validation)
  - [Plugin Settings](#plugin-settings)
- [Usage](#usage)
- [AI Providers and Models](#ai-providers-and-models)
  - [OpenAI](#openai)
  - [Ollama](#ollama)
  - [Google Gemini](#google-gemini)
  - [Mistral AI](#mistral-ai)
  - [Anthropic (Claude)](#anthropic-claude)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Changelog](#changelog)

## Features

- Provides intelligent command suggestions and completions
- Supports multiple AI providers: OpenAI, Ollama, Google Gemini, Mistral AI, and Anthropic (Claude)
- Customizable keyboard shortcut to trigger suggestions
- Option to include system context in prompts
- Debug logging for troubleshooting
- API key validation for supported providers
- Wide range of AI models available for different needs and performances

## Prerequisites

- Zsh (version 5.0 or higher)
- curl
- jq
- An account and API key for at least one of the supported AI providers

## Installation

### Installing Dependencies

Choose the instructions corresponding to your operating system:

#### Debian/Ubuntu and derivatives

```bash
sudo apt update
sudo apt install zsh curl jq
```

#### Fedora

```bash
sudo dnf install zsh curl jq
```

#### Arch Linux and derivatives (Manjaro, EndeavourOS, etc.)

```bash
sudo pacman -Syu zsh curl jq
```

#### openSUSE

```bash
sudo zypper install zsh curl jq
```

#### macOS with Homebrew

```bash
brew install zsh curl jq
```

#### macOS with MacPorts

```bash
sudo port install zsh curl jq
```

#### FreeBSD

```bash
sudo pkg install zsh curl jq
```

#### Windows with Windows Subsystem for Linux (WSL)

Follow the instructions for your Linux distribution under WSL (typically Debian/Ubuntu).

#### Windows with Cygwin

Use the Cygwin installer to install `zsh`, `curl`, and `jq`.

### Installing Zsh Copilot

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/zsh-copilot.git ~/.zsh/zsh-copilot
   ```

2. Add the following to your `~/.zshrc`:
   ```zsh
   source ~/.zsh/zsh-copilot/zsh-copilot.zsh
   ```

3. Reload your Zsh configuration or restart your terminal:
   ```bash
   source ~/.zshrc
   ```

## Configuration

### API Keys

Set your API keys in your `~/.zshrc` or `~/.zshenv`:

```zsh
export OPENAI_API_KEY="your_openai_api_key_here"
export GOOGLE_API_KEY="your_google_api_key_here"
export MISTRAL_API_KEY="your_mistral_api_key_here"
export CLAUDE_API_KEY="your_claude_api_key_here"
```

### API Key Validation

Zsh Copilot includes API key validation for supported providers:

- The plugin checks the validity of your API keys when it's first loaded.
- If a key is missing or appears to be invalid, you'll see a warning message.
- This check is performed only once per session to avoid unnecessary API calls.

If you see a warning about your API key:

1. Make sure you've correctly set the API key in your `~/.zshrc` or `~/.zshenv`.
2. Check that your API key is valid and has the necessary permissions.
3. If the issue persists, there might be a connection problem to the API service.

You can manually trigger a re-check of your API keys by reloading your Zsh configuration:

```bash
source ~/.zshrc
```

### Plugin Settings

The plugin comes with default settings, but you can customize them if needed. These settings are defined in the `zsh-copilot-user-config.zsh` file. You can modify them by directly editing this file or by overriding them in your `~/.zshrc`:

```zsh
# Keyboard shortcut to trigger Zsh Copilot (default: ^z)
ZSH_COPILOT_KEY='^z'
# Whether to send context information to the AI model (default: true)
ZSH_COPILOT_SEND_CONTEXT=true
# AI provider to use: "openai", "ollama", "gemini", "mistral", or "claude" (default: claude)
ZSH_COPILOT_LLM_PROVIDER="claude"
# OpenAI model to use (default: gpt-4)
ZSH_COPILOT_OPENAI_MODEL="gpt-4"
# Ollama model to use (default: zsh)
ZSH_COPILOT_OLLAMA_MODEL="llama3.1"
# Google Gemini model to use (default: gemini-1.5-pro)
ZSH_COPILOT_GEMINI_MODEL="gemini-1.5-pro"
# Mistral model to use (default: mistral-large-latest)
ZSH_COPILOT_MISTRAL_MODEL="mistral-large-latest"
# Anthropic (Claude) model to use (default: claude-3-5-sonnet-20240620)
ZSH_COPILOT_ANTHROPIC_MODEL="claude-3-5-sonnet-20240620"
# Enable debug logging (default: false)
ZSH_COPILOT_DEBUG=false
```

## Usage

1. Type a partial command or describe what you want to do.
2. Press the configured key (default: Ctrl+Z) to trigger Zsh Copilot.
3. Zsh Copilot will complete your command or suggest a new one.

Example:
```
$ list files in current directory<Ctrl+Z>
$ ls -la # ls is the command to list files and directories
```

## AI Providers and Models

Creation date: March 20, 2024
Last updated: March 20, 2024

### OpenAI

Updated: March 20, 2024

OpenAI offers a range of powerful GPT (Generative Pre-trained Transformer) models.

**Available models:**
- GPT-4 (recommended): Our high-intelligence flagship model for complex, multi-step tasks
- GPT-4 Turbo: Enhanced version of GPT-4 with superior performance
- GPT-4o mini: Small and affordable model for fast, lightweight tasks
- GPT-4o1-preview and GPT-4o1-mini: Language models trained with reinforcement learning to perform complex reasoning
- GPT-3.5 Turbo: A fast, inexpensive model for simple tasks

For more information on OpenAI models, check the [official OpenAI documentation](https://platform.openai.com/docs/models).

### Ollama

Updated: March 20, 2024

Ollama allows you to run language models locally on your machine.

**Available models:**
- llama3.1: New state-of-the-art model from Meta available in 8B, 70B, and 405B parameter sizes
- gemma2: Google Gemma 2 high-performing and efficient model available in three sizes: 2B, 9B, and 27B
- mistral-nemo: A state-of-the-art 12B model with 128k context length, built by Mistral AI in collaboration with NVIDIA
- mistral-large: Mistral's new flagship model that is significantly more capable in code generation, mathematics, and reasoning with 128k context window
- qwen2: New series of large language models from Alibaba group
- deepseek-coder-v2: An open-source Mixture-of-Experts code language model
- phi3: Family of lightweight 3B (Mini) and 14B (Medium) state-of-the-art open models by Microsoft
- mistral: The 7B model released by Mistral AI, updated to version 0.3
- mixtral: Set of Mixture of Experts (MoE) models with open weights by Mistral AI in 8x7b and 8x22b parameter sizes

For a complete list of Ollama models, check the [Ollama documentation](https://ollama.ai/library).

### Google Gemini

Updated: March 20, 2024

Google Gemini is Google's new generation of AI models.

**Available models:**
- Gemini 1.5 Flash (`gemini-1.5-flash`): Optimized for speed and versatility in various tasks
- Gemini 1.5 Pro (`gemini-1.5-pro`): For complex reasoning tasks such as code generation and text generation
- Gemini 1.0 Pro (`gemini-1.0-pro`): For natural language tasks and code generation
- Text Embedding (`text-embedding-004`): For measuring the relationship between text strings
- AQA (`aqa`): For providing source-based question answers

For more information on Gemini models, check the [Google AI documentation](https://ai.google.dev/models/gemini).

### Mistral AI

Updated: March 20, 2024

Mistral AI offers powerful and efficient language models.

**Available models:**
- Mistral Large: Flagship model with state-of-the-art reasoning, knowledge, and coding capabilities (128k tokens)
- Mistral Nemo: 12B model built in partnership with Nvidia (128k tokens)
- Codestral: A generative model specifically designed and optimized for code generation tasks (32k tokens)
- Mistral Embed: Model that converts text into numerical vectors of embeddings in 1024 dimensions (8k tokens)

For more details on Mistral models, visit the [official Mistral AI website](https://mistral.ai/).

### Anthropic (Claude)

Updated: March 20, 2024

Anthropic offers Claude, an advanced AI assistant.

**Available models:**
- Claude 3.5 Opus: Available later this year
- Claude 3.5 Sonnet (`claude-3-5-sonnet-20240620`)
- Claude 3.5 Haiku: Available later this year
- Claude 3 Opus (`claude-3-opus-20240229`)
- Claude 3 Sonnet (`claude-3-sonnet-20240229`)
- Claude 3 Haiku (`claude-3-haiku-20240307`)

These models are available via the Anthropic API, AWS Bedrock, and GCP Vertex AI.

For more information on Claude models, check the [Anthropic documentation](https://www.anthropic.com/product).

## Troubleshooting

If you encounter any issues:

1. Make sure your API keys are correctly set and valid.
2. Check that all required files are in the correct location.
3. Enable debug logging by setting `ZSH_COPILOT_DEBUG=true` in your `~/.zshrc`.
4. Check the log file at `$ZSH_COPILOT_LOG_FILE` for error messages.
5. Ensure all dependencies are correctly installed and up to date.
6. If you're using Ollama, verify that the Ollama service is running on your local machine.
7. For provider-specific issues, consult their respective documentation for troubleshooting.

## Contributing

Contributions are welcome! Here's how you can contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Make sure to adhere to the existing code style and add tests for new features.

## Changelog

### v1.2.0 (2024-03-20)
- Added support for new OpenAI, Ollama, Google Gemini, Mistral AI, and Anthropic models
- Updated installation instructions to include more Linux distributions
- Improved documentation on available models for each provider
- Optimized performance for complex command suggestions

### v1.1.0 (2023-09-18)
- Added support for Google Gemini API
- Implemented Mistral API integration
- Updated configuration options to include new AI providers
- Enhanced API key validation to support all providers
- Updated README with new provider information and configuration options
- Improved error handling and debug logging for new providers

### v1.0.4 (2023-09-17)
- Removed comments from Ollama suggestions
- Improved handling of AI suggestions in the main script
- Updated `get_ai_suggestion` function to clean responses
- Enhanced debug logging for better troubleshooting

### v1.0.3 (2023-09-17)
- Fixed "command not found: zsh_copilot_debug" error
- Reorganized code to ensure debug function is defined before use
- Improved debug logging across all plugin files

### v1.0.2 (2023-09-17)
- Added API key validation feature
- Updated configuration section in README to clarify plugin settings
- Improved troubleshooting section with API key validation information

### v1.0.1 (2023-09-17)
- Fixed issue with repeated OpenAI API key warnings
- Improved README with detailed installation and configuration instructions
- Added changelog to README

### v1.0.0 (2023-09-17)
- Initial release
- Support for OpenAI and Ollama as AI providers
- Customizable key binding
- Context-aware suggestions
- Debug logging
- Personalized "Thinking" messages based on AI provider

## License

Zsh Copilot is distributed under the GNU General Public License version 3 (GPLv3). Here's a summary of the license (this is not a substitute for the full license text):

```
Zsh Copilot - An AI-powered command-line assistant
Copyright (C) 2024 ShadowDev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

The full text of the GPLv3 license is available in the `LICENSE` file included with this software and can also be viewed online at: [https://www.gnu.org/licenses/gpl-3.0.en.html](https://www.gnu.org/licenses/gpl-3.0.en.html)

### Implications of the GPLv3 License

By choosing the GPLv3 license, we ensure that:

1. The source code of Zsh Copilot remains open and accessible to everyone.
2. You are free to use, modify, and distribute Zsh Copilot.
3. If you distribute modified versions of Zsh Copilot, you must do so under the same license (GPLv3) and provide the source code.
4. Any derivative work or software that incorporates Zsh Copilot must also be distributed under the GPLv3 license.

This license ensures that Zsh Copilot and all its derivative versions will remain free and open-source software, preserving users' freedoms.

---

Thank you for using Zsh Copilot! If you appreciate this project, please consider giving it a star on GitHub and sharing it with your fellow developers. For any questions or suggestions, please open an issue on the project's GitHub repository.

---

## Version Française

[Aller à la version anglaise](#english-version)

# Zsh Copilot

Zsh Copilot est un assistant de ligne de commande alimenté par l'IA qui vous aide avec les commandes shell en utilisant divers modèles d'IA de pointe.

## Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Prérequis](#prérequis)
- [Installation](#installation)
  - [Installation des dépendances](#installation-des-dépendances)
  - [Installation de Zsh Copilot](#installation-de-zsh-copilot)
- [Configuration](#configuration)
  - [Clés API](#clés-api)
  - [Validation des clés API](#validation-des-clés-api)
  - [Paramètres du plugin](#paramètres-du-plugin)
- [Utilisation](#utilisation)
- [Fournisseurs d'IA et modèles](#fournisseurs-dia-et-modèles)
  - [OpenAI](#openai)
  - [Ollama](#ollama)
  - [Google Gemini](#google-gemini)
  - [Mistral AI](#mistral-ai)
  - [Anthropic (Claude)](#anthropic-claude)
- [Dépannage](#dépannage)
- [Contribution](#contribution)
- [Changelog](#changelog)

## Fonctionnalités

- Fournit des suggestions de commandes intelligentes et des complétions
- Prend en charge plusieurs fournisseurs d'IA : OpenAI, Ollama, Google Gemini, Mistral AI et Anthropic (Claude)
- Raccourci clavier personnalisable pour déclencher les suggestions
- Option pour inclure le contexte système dans les prompts
- Journalisation de débogage pour le dépannage
- Validation des clés API pour les fournisseurs pris en charge
- Large gamme de modèles d'IA disponibles pour différents besoins et performances

## Prérequis

- Zsh (version 5.0 ou supérieure)
- curl
- jq
- Un compte et une clé API pour au moins l'un des fournisseurs d'IA pris en charge

## Installation

### Installation des dépendances

Choisissez les instructions correspondant à votre système d'exploitation :

#### Debian/Ubuntu et dérivés

```bash
sudo apt update
sudo apt install zsh curl jq
```

#### Fedora

```bash
sudo dnf install zsh curl jq
```

#### Arch Linux et dérivés (Manjaro, EndeavourOS, etc.)

```bash
sudo pacman -Syu zsh curl jq
```

#### openSUSE

```bash
sudo zypper install zsh curl jq
```

#### macOS avec Homebrew

```bash
brew install zsh curl jq
```

#### macOS avec MacPorts

```bash
sudo port install zsh curl jq
```

#### FreeBSD

```bash
sudo pkg install zsh curl jq
```

#### Windows avec Windows Subsystem for Linux (WSL)

Suivez les instructions pour votre distribution Linux sous WSL (généralement Debian/Ubuntu).

#### Windows avec Cygwin

Utilisez l'installateur Cygwin pour installer `zsh`, `curl`, et `jq`.

### Installation de Zsh Copilot

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/yourusername/zsh-copilot.git ~/.zsh/zsh-copilot
   ```

2. Ajoutez ce qui suit à votre `~/.zshrc` :
   ```zsh
   source ~/.zsh/zsh-copilot/zsh-copilot.zsh
   ```

3. Rechargez votre configuration Zsh ou redémarrez votre terminal :
   ```bash
   source ~/.zshrc
   ```

## Configuration

### Clés API

Définissez vos clés API dans votre `~/.zshrc` ou `~/.zshenv` :

```zsh
export OPENAI_API_KEY="votre_clé_api_openai_ici"
export GOOGLE_API_KEY="votre_clé_api_google_ici"
export MISTRAL_API_KEY="votre_clé_api_mistral_ici"
export CLAUDE_API_KEY="votre_clé_api_claude_ici"
```

### Validation des clés API

Zsh Copilot inclut une validation des clés API pour les fournisseurs pris en charge :

- Le plugin vérifie la validité de vos clés API lors de son premier chargement.
- Si une clé est manquante ou semble invalide, vous verrez un message d'avertissement.
- Cette vérification n'est effectuée qu'une fois par session pour éviter des appels API inutiles.

Si vous voyez un avertissement concernant votre clé API :

1. Assurez-vous d'avoir correctement défini la clé API dans votre `~/.zshrc` ou `~/.zshenv`.
2. Vérifiez que votre clé API est valide et dispose des autorisations nécessaires.
3. Si le problème persiste, il peut y avoir un problème de connexion au service API.

Vous pouvez déclencher manuellement une nouvelle vérification de vos clés API en rechargeant votre configuration Zsh :

```bash
source ~/.zshrc
```

### Paramètres du plugin

Le plugin est livré avec des paramètres par défaut, mais vous pouvez les personnaliser si nécessaire. Ces paramètres sont définis dans le fichier `zsh-copilot-user-config.zsh`. Vous pouvez les modifier en éditant directement ce fichier ou en les surchargeant dans votre `~/.zshrc` :

```zsh
# Raccourci clavier pour déclencher Zsh Copilot (par défaut : ^z)
ZSH_COPILOT_KEY='^z'
# Envoyer ou non les informations de contexte au modèle d'IA (par défaut : true)
ZSH_COPILOT_SEND_CONTEXT=true
# Fournisseur d'IA à utiliser : "openai", "ollama", "gemini", "mistral" ou "claude" (par défaut : claude)
ZSH_COPILOT_LLM_PROVIDER="claude"
# Modèle OpenAI à utiliser (par défaut : gpt-4)
ZSH_COPILOT_OPENAI_MODEL="gpt-4"
# Modèle Ollama à utiliser (par défaut : zsh)
ZSH_COPILOT_OLLAMA_MODEL="llama3.1"
# Modèle Google Gemini à utiliser (par défaut : gemini-1.5-pro)
ZSH_COPILOT_GEMINI_MODEL="gemini-1.5-pro"
# Modèle Mistral à utiliser (par défaut : mistral-large-latest)
ZSH_COPILOT_MISTRAL_MODEL="mistral-large-latest"
# Modèle Anthropic (Claude) à utiliser (par défaut : claude-3-5-sonnet-20240620)
ZSH_COPILOT_ANTHROPIC_MODEL="claude-3-5-sonnet-20240620"
# Activer la journalisation de débogage (par défaut : false)
ZSH_COPILOT_DEBUG=false
```

## Utilisation

1. Tapez une commande partielle ou décrivez ce que vous voulez faire.
2. Appuyez sur la touche configurée (par défaut : Ctrl+Z) pour déclencher Zsh Copilot.
3. Zsh Copilot complétera votre commande ou suggérera une nouvelle.

Exemple :
```
$ list files in current directory<Ctrl+Z>
$ ls -la # ls est la commande pour lister les fichiers et répertoires
```

## Fournisseurs d'IA et modèles

Date de création : 20 mars 2024
Dernière mise à jour : 20 mars 2024

### OpenAI

Mise à jour : 20 mars 2024

OpenAI propose une gamme de modèles GPT (Generative Pre-trained Transformer) puissants.

**Modèles disponibles :**
- GPT-4 (recommandé) : Notre modèle phare de haute intelligence pour des tâches complexes et multi-étapes
- GPT-4 Turbo : Version améliorée de GPT-4 avec des performances supérieures
- GPT-4o mini : Modèle petit et abordable pour des tâches rapides et légères
- GPT-4o1-preview et GPT-4o1-mini : Modèles de langage entraînés avec apprentissage par renforcement pour effectuer des raisonnements complexes
- GPT-3.5 Turbo : Un modèle rapide et peu coûteux pour des tâches simples

Pour plus d'informations sur les modèles OpenAI, consultez la [documentation officielle d'OpenAI](https://platform.openai.com/docs/models).

### Ollama

Mise à jour : 20 mars 2024

Ollama permet d'exécuter des modèles de langage localement sur votre machine.

**Modèles disponibles :**
- llama3.1 : Nouveau modèle à la pointe de la technologie de Meta, disponible en tailles de 8B, 70B et 405B paramètres
- gemma2 : Modèle Google Gemma 2 haute performance et efficace, disponible en trois tailles : 2B, 9B et 27B
- mistral-nemo : Modèle 12B à la pointe de la technologie avec une longueur de contexte de 128k, construit par Mistral AI en collaboration avec NVIDIA
- mistral-large : Nouveau modèle phare de Mistral, plus performant en génération de code, mathématiques et raisonnement avec une fenêtre de contexte de 128k
- qwen2 : Nouvelle série de grands modèles de langage du groupe Alibaba
- deepseek-coder-v2 : Modèle de langage de code open-source basé sur le mélange d'experts
- phi3 : Famille de modèles ouverts légers 3B (Mini) et 14B (Medium) à la pointe de la technologie par Microsoft
- mistral : Le modèle 7B publié par Mistral AI, mis à jour à la version 0.3
- mixtral : Ensemble de modèles Mixture of Experts (MoE) avec poids ouverts par Mistral AI en tailles de paramètres 8x7b et 8x22b

Pour une liste complète des modèles Ollama, consultez la [documentation Ollama](https://ollama.ai/library).

### Google Gemini

Mise à jour : 20 mars 2024

Google Gemini est la nouvelle génération de modèles d'IA de Google.

**Modèles disponibles :**
- Gemini 1.5 Flash (`gemini-1.5-flash`) : Optimisé pour la rapidité et la polyvalence dans diverses tâches
- Gemini 1.5 Pro (`gemini-1.5-pro`) : Pour les tâches de raisonnement complexes comme la génération de code et de texte
- Gemini 1.0 Pro (`gemini-1.0-pro`) : Pour les tâches en langage naturel et la génération de code
- Intégration de texte (`text-embedding-004`) : Pour mesurer la relation entre des chaînes de texte
- AQA (`aqa`) : Pour fournir des réponses aux questions basées sur la source

Pour plus d'informations sur les modèles Gemini, consultez la [documentation Google AI](https://ai.google.dev/models/gemini).

### Mistral AI

Mise à jour : 20 mars 2024

Mistral AI propose des modèles de langage puissants et efficaces.

**Modèles disponibles :**
- Mistral Large : Modèle phare avec des capacités de raisonnement, de connaissance et de codage à la pointe de la technologie (128k tokens)
- Mistral Nemo : Modèle 12B construit en partenariat avec Nvidia (128k tokens)
- Codestral : Modèle génératif spécialement conçu et optimisé pour les tâches de génération de code (32k tokens)
- Mistral Embed : Modèle qui convertit le texte en vecteurs numériques d'embeddings en 1024 dimensions (8k tokens)

Pour plus de détails sur les modèles Mistral, visitez le [site officiel de Mistral AI](https://mistral.ai/).

### Anthropic (Claude)

Mise à jour : 20 mars 2024

Anthropic propose Claude, un assistant IA avancé.

**Modèles disponibles :**
- Claude 3.5 Opus : Disponible plus tard cette année
- Claude 3.5 Sonnet (`claude-3-5-sonnet-20240620`)
- Claude 3.5 Haiku : Disponible plus tard cette année
- Claude 3 Opus (`claude-3-opus-20240229`)
- Claude 3 Sonnet (`claude-3-sonnet-20240229`)
- Claude 3 Haiku (`claude-3-haiku-20240307`)

Ces modèles sont disponibles via l'API Anthropic, AWS Bedrock, et GCP Vertex AI.

Pour plus d'informations sur les modèles Claude, consultez la [documentation Anthropic](https://www.anthropic.com/product).

## Dépannage

Si vous rencontrez des problèmes :

1. Assurez-vous que vos clés API sont correctement définies et valides.
2. Vérifiez que tous les fichiers requis sont au bon endroit.
3. Activez la journalisation de débogage en définissant `ZSH_COPILOT_DEBUG=true` dans votre `~/.zshrc`.
4. Vérifiez le fichier journal à `$ZSH_COPILOT_LOG_FILE` pour les messages d'erreur.
5. Assurez-vous que toutes les dépendances sont correctement installées et à jour.
6. Si vous utilisez Ollama, vérifiez que le service Ollama est en cours d'exécution sur votre machine locale.
7. Pour les problèmes spécifiques à un fournisseur d'IA, consultez leur documentation respective pour le dépannage.

## Contribution

Les contributions sont les bienvenues ! Voici comment vous pouvez contribuer :

1. Forkez le dépôt
2. Créez votre branche de fonctionnalité (`git checkout -b ma-nouvelle-fonctionnalite`)
3. Committez vos changements (`git commit -am 'Ajout de quelque chose de nouveau'`)
4. Poussez vers la branche (`git push origin ma-nouvelle-fonctionnalite`)
5. Créez une nouvelle Pull Request

Assurez-vous de respecter le style de code existant et d'ajouter des tests pour les nouvelles fonctionnalités.

## Changelog

### v1.2.0 (2024-03-20)
- Ajout du support pour les nouveaux modèles OpenAI, Ollama, Google Gemini, Mistral AI et Anthropic
- Mise à jour des instructions d'installation pour inclure plus de distributions Linux
- Amélioration de la documentation sur les modèles disponibles pour chaque fournisseur
- Optimisation des performances pour les suggestions de commandes complexes

### v1.1.0 (2023-09-18)
- Ajout du support pour l'API Google Gemini
- Implémentation de l'intégration de l'API Mistral
- Mise à jour des options de configuration pour inclure les nouveaux fournisseurs d'IA
- Amélioration de la validation des clés API pour prendre en charge tous les fournisseurs
- Mise à jour du README avec les nouvelles informations sur les fournisseurs et les options de configuration
- Amélioration de la gestion des erreurs et de la journalisation de débogage pour les nouveaux fournisseurs

### v1.0.4 (2023-09-17)
- Suppression des commentaires des suggestions Ollama
- Amélioration de la gestion des suggestions d'IA dans le script principal
- Mise à jour de la fonction `get_ai_suggestion` pour nettoyer les réponses
- Amélioration de la journalisation de débogage pour un meilleur dépannage

### v1.0.3 (2023-09-17)
- Correction de l'erreur "command not found: zsh_copilot_debug"
- Réorganisation du code pour s'assurer que la fonction de débogage est définie avant utilisation
- Amélioration de la journalisation de débogage dans tous les fichiers du plugin

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