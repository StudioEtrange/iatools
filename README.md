# IATools

IATools is an experimental swiss-knife command-line application designed to streamline the installation and management of AI development tools, including `gemini-cli`, `opencode` and various MCP servers. The main goal is to provide a convenient way to install and configure AI tools, ensuring minimal system, to test or use them.

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

| Command | Description |
| - | - |
| **init** | Install/Reinstall dependencies |
| **help** | Display help message |
| **shell** | Enter a sub-shell with the `iatools` environment and paths configured |

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

See [Gemini CLI](doc/geminicli.md) 

### Opencode

See [Opencode](doc/opencode.md) 

### VS Code

See [VS Code](doc/vscode.md) 

### CLIProxyAPI

See [CLIProxyAPI](doc/cliproxyapi.md) 

### MCP Servers

IATools simplifies connecting to MCP (Model Context Protocol) servers, allowing your AI agents to interact with external tools and services.
* **Catalogs**: [MCPMarket](https://mcpmarket.com/), [PulseMCP](https://www.pulsemcp.com/servers), [MCPServers.org](https://mcpservers.org/)

**Supported MCP Servers:**
* **Desktop Commander**: Grants terminal control and file system access. ([Source](https://github.com/wonderwhy-er/desktopcommandermcp))
* **Calculator**: A simple server for performing calculations. ([Source](https://github.com/githejie/mcp-server-calculator))
* **Context7**: Fetches up-to-date documentation and code examples. ([Source](https://github.com/upstash/context7)). https://context7.com/
* **GitHub**: Official server for interacting with GitHub issues, PRs, and repositories. ([Source](https://github.com/github/github-mcp-server))
* **Data Commons**: Tools and agents for interacting with the Data Commons Knowledge Graph using the Model Context Protocol (MCP). ([Source](https://github.com/datacommonsorg/agent-toolkit))

### Agent Skills

* spec : https://github.com/agentskills/agentskills
* home : https://agentskills.io/

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





## TODO and VARIOUS NOTES

* kilocode vsextension config home : $HOME/.vscode-server/data/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json
  * https://kilo.ai/docs/automate/mcp/using-in-cli
* process manager goreman https://github.com/mattn/goreman


## Contributors

See the [CONTRIBUTORS](CONTRIBUTORS) file for the full list of contributors

## License

Licensed under the **Apache License, Version 2.0**.

Copyright © 2025-2026 **Sylvain Boucault**.

See the [LICENSE](LICENSE) file for details.