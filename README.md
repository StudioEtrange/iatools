# IATools

IATools is a command-line application designed to streamline the installation and management of AI development tools, including `gemini-cli`, `opencode` and various MCP servers.

## Key Features of IATools

*   **AI Tool Management**: Streamlines the installation and configuration of AI agents like `gemini-cli` and `opencode`. Provides some minimal convenient default settings.
*   **MCP Server Integration**: Easily configure and manage connections to various MCP (Model Context Protocol) servers.
*   **Isolated Environments**: All tools are installed into a local `workspace/` directory, preventing system-wide conflicts. Installing any agent or MCP server will not pollute in anyway your system nor your development environment path with its own dependencies (nodejs, python, ...). Everything is contained in an easy deletable internal folder.
*   **Portability**: Bash application, works on Linux & MacOS.

## Getting Started

### Requirements

*   `bash`
*   `git`

### Commands

`iatools` provides a simple command-line interface to manage your tools and environments.

| Command                                                 | Description                                                                                                                              |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **init**                                                | Install/Reinstall dependencies.                                                                                                          |
| **help**                                                | Display this help message.                                                                                                               |
| **shell**                                               | Enter a sub-shell with the `iatools` environment and paths configured.                                                                    |
| |
| **gc install [@version]**                               | Install and configure a specific version of Gemini CLI (e.g., `@latest`, `@nightly`, `@preview`).                                        |
| **gc uninstall**                                        | Uninstall Gemini CLI (keeps configuration).                                                                                              |
| **gc configure**                                        | (Re)Configure Gemini CLI.                                                                                                                |
| **gc show-config**                                      | Show the current Gemini CLI configuration.                                                                                               |
| **gc reset**                                            | Reset all Gemini CLI configuration.                                                                                                      |
| **gc launch [ctx] -- <opts>**                           | Launch Gemini CLI, optionally in a specific context folder, passing extra options.                                                       |
| **gc mcp calculator install\|uninstall**                | Add or remove the `calculator` MCP server for Gemini CLI.                                                                                |
| **gc mcp github install\|uninstall**                    | Add or remove the `github` MCP server for Gemini CLI.                                                                                    |
| **gc mcp desktop-commander install\|uninstall**         | Add or remove the `desktop-commander` MCP server for Gemini CLI.                                                                         |
| **gc mcp context7 install\|uninstall [CONTEXT7_API_KEY]**        | Add or remove the `context7` MCP server for Gemini CLI, with an optional API key given as argument or CONTEXT7_API_KEY.                  |
| **gc mcp data-commons install\|uninstall [DC_API_KEY]**    | Add or remove the `data-commons` MCP server for Gemini CLI (requires an API key as argument or DC_API_KEY env var).                      |
| |
| **oc install**                                          | Install and configure Opencode CLI.                                                                                                      |
| **oc uninstall**                                        | Uninstall Opencode CLI (keeps configuration).                                                                                            |
| **oc configure**                                        | (Re)Configure Opencode CLI.                                                                                                              |
| **oc show-config**                                      | Show the current Opencode CLI configuration.                                                                                             |
| **oc reset**                                            | Reset all Opencode CLI configuration.                                                                                                    |
| **oc launch [ctx] -- <opts>**                           | Launch Opencode CLI, optionally in a specific context folder, passing extra options.                                                     |
| **oc mcp calculator install\|uninstall**                | Add or remove the `calculator` MCP server for Opencode CLI.                                                                              |
| **oc mcp github install\|uninstall**                    | Add or remove the `github` MCP server for Opencode CLI.                                                                                  |
| **oc mcp context7 install\|uninstall**                  | Add or remove the `context7` MCP server for Opencode CLI.                                                                                |
| |
| **npm-config set <key> <value>**                        | Set a global configuration for the internal `npm`.                                                                                       |

### How-To


**Install and configure gemini-cli from scratch**

```
git clone https://github.com/StudioEtrange/iatools
cd iatools
./iatools init
./iatools gc install
```

**Register local MCP server calculator**
```
cd iatools
./iatools mcp calculator install
```

**Configure the underlying nodejs to add a local npm registry**
```
cd iatools
./iatools npm-config set registry https://registry.local.org/
```

## Directory Structure

*   `iatools/`: Contains the main application logic for the `iatools` wrapper script.
*   `lib/`: ITools internal libraries and code.
*   `pool/`: Contains configuration files templates and framework.
*   `workspace/`: The directory where all isolated environments and installed software ("features") are stored.

## Integrations

### Gemini CLI

An open-source AI agent that brings the power of Gemini directly into your terminal.
* **Website**: [google-gemini.github.io/gemini-cli](https://google-gemini.github.io/gemini-cli)
* **Source**: [github.com/google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli)
* **IDE Integration**: 
  * When you run Gemini CLI inside a supported editor, it will automatically detect your environment and prompt you to connect.
  * Manual installation : use `/ide install` - if you install vscode extension with /ide install and have problem, just close and relaunch vscode
  * Other Manual Installation : https://marketplace.visualstudio.com/items?itemName=Google.gemini-cli-vscode-ide-companion


*NOTES*
* Installing Gemini CLI with iatools set some convenient default settings
  * disable usage statistics
  * gemini-cli will read AGENTS.md by default
* Gemini CLI supports MCP Prompts as slash commands
* `/chat save` - saved chat history are in $HOME/.gemini/tmp
* gemini 2.5 pro is only free of charge when using google auth inside gemini-cli. If you set a gemini key, by using GEMINI_API_KEY, it will not be free (even if you previously with google auth)

### Opencode CLI

An AI coding agent built for the terminal.
* **Website**: [opencode.ai](https://opencode.ai)
* **Source**: [github.com/sst/opencode](https://github.com/sst/opencode)
* **IDE Integration**: Integrates with VS Code, Cursor, and other IDEs by running `opencode` in the integrated terminal.

*NOTES*
  * First step : init IA provider : `opencode auth login`

### MCP Servers

IATools simplifies connecting to MCP (Model Context Protocol) servers, allowing your AI agents to interact with external tools and services.
* **Catalogs**: [MCPMarket](https://mcpmarket.com/), [PulseMCP](https://www.pulsemcp.com/servers), [MCPServers.org](https://mcpservers.org/)

**Supported MCP Servers:**
* **Desktop Commander**: Grants terminal control and file system access. ([Source](https://github.com/wonderwhy-er/desktopcommandermcp))
* **Calculator**: A simple server for performing calculations. ([Source](https://github.com/githejie/mcp-server-calculator))
* **Context7**: Fetches up-to-date documentation and code examples. ([Source](https://github.com/upstash/context7)). https://context7.com/
* **GitHub**: Official server for interacting with GitHub issues, PRs, and repositories. ([Source](https://github.com/github/github-mcp-server))
* **Data Commons**: Tools and agents for interacting with the Data Commons Knowledge Graph using the Model Context Protocol (MCP). ([Source](https://github.com/datacommonsorg/agent-toolkit))


## Design Notes 

### Notes on underlying Framework: Stella

IATools leverages the **Stella** framework for its core functionality. Stella provides the infrastructure for application structure, environment isolation, and package management. **Package Management**: Stella uses a concept of "Features" (software packages) which are defined by "Recipes" (Bash scripts). `iatools` uses this system to provide all the tools it manages. The recipes are located in `pool/stella/nix/pool/feature-recipe/`.

### Notes on using nodejs, npx, npm

* `npx` command to needs at least `node` binary in PATH and `sh` binary in PATH

* any mcp server based on node have 2 ways to be registered :
  
  A standard way using json in settings.json settings PATH to node binaries and `sh` (using STELLA_ORIGINAL_SYSTEM_PATH stella environment variable for reach `sh` binary)

  * registered mcp server desktop-commander :
  ```
  {
    "mcpServers": {
      "desktop-commander": {
        "command": "npx",
        "args": [
          "-y",
          "@wonderwhy-er/desktop-commander"
        ],
        "env": {
            "PATH": "${IATOOLS_NODEJS_BIN_PATH}:${STELLA_ORIGINAL_SYSTEM_PATH}"
        }
      }
    }
  }
  ```

  Or an indirect way using a script as launcher
  * registered mcp server context7 :
  ```
  {
    "mcpServers": {
      "context7": {
        "command": "${IATOOLS_MCP_LAUNCHER_HOME}/context7"
      }
    }
  }
  ```
  * script launcher for context7 :
  ```
  #!/bin/sh
  export PATH="/home/nomorgan/workspace/iatools/workspace/isolated_dependencies/nodejs/bin/:${PATH}"
  exec "npx" -y @upstash/context7-mcp --api-key "${CONTEXT7_API_KEY}"
  ```





## TODO

* kilocode and roocode can use gemini-cli as LLM provider
* kilocode vsextension config home : $HOME/.vscode-server/data/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json
* LiteLLM and gemini-cli https://docs.litellm.ai/docs/tutorials/litellm_gemini_cli
* process manager goreman https://github.com/mattn/goreman
* override gemini-cli with GEMINI_API_KEY, GEMINI_MODEL, GOOGLE_GEMINI_BASE_URL
* gemini api compatible openai : 
  * https://ai.google.dev/gemini-api/docs/openai?hl=fr#rest
  * https://github.com/PublicAffairs/openai-gemini
  * https://github.com/zhu327/gemini-openai-proxy https://deepwiki.com/zhu327/gemini-openai-proxy
  * https://huggingface.co/engineofperplexity/gemini-openai-proxy/blob/main/readme.md



## License

Licensed under the **Apache License, Version 2.0**.

Copyright © 2025-2026 **Sylvain Boucault**.

See the [LICENSE](LICENSE) file for details.