# IATools

IATools is a command-line application designed to streamline the installation and management of AI development tools, including `gemini-cli`, `opencode`, and various MCP servers.

## Key Features of IATools

*   **AI Tool Management**: Streamlines the installation and configuration of AI agents like `gemini-cli` and `opencode`.
*   **MCP Server Integration**: Easily configure and manage connections to various MCP (Model Context Protocol) servers.
*   **Isolated Environments**: All tools are installed into a local `workspace/` directory, preventing system-wide conflicts.
*   **Portability**: Bash application, works on Linux & MacOS.

## Getting Started

### Requirements

*   `bash`
*   `git`

### Commands

`iatools` provides a simple command-line interface to manage your tools and environments.

| Command                             | Description                                                                 |
| ----------------------------------- | --------------------------------------------------------------------------- |
| **init**                            | Install/Reinstall dependencies.                                             |
| **help**                            | Display this help message.                                                  |
| |
| **gc install [@version]**           | Install and configure Gemini CLI (e.g., `@latest`, `@nightly`).             |
| **gc uninstall**                    | Uninstall Gemini CLI (keeps config).                                        |
| **gc configure**                    | Configure Gemini CLI.                                                       |
| **gc reset**                        | Reset all Gemini CLI configuration.                                         |
| **gc launch [ctx] -- <opts>**       | Launch Gemini CLI, optionally in a specific context folder.                 |
| **gc cmd-plan install\|uninstall**   | Add or remove the 'plan' command to Gemini CLI.                             |
| **gc mcp [name] install\|uninstall** | Add or remove an MCP server configuration for Gemini CLI.                   |
| |
| **oc install**                      | Install and configure Opencode CLI.                                         |
| **oc uninstall**                    | Uninstall Opencode CLI (keeps config).                                      |
| **oc configure**                    | Configure Opencode CLI.                                                     |
| **oc reset**                        | Reset all Opencode CLI configuration.                                       |
| **oc launch [ctx] -- <opts>**       | Launch Opencode CLI, optionally in a specific context folder.               |
| **oc mcp [name] install\|uninstall** | Add or remove an MCP server configuration for Opencode CLI.                 |
| |
| **npm-config set <key> <value>**    | Set a configuration for the internal npm.                                   |

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
* Gemini CLI supports MCP Prompts as slash commands
* `/chat save` - saved chat history are in $HOME/.gemini/tmp
* gemini 2.5 pro is only free of charge when using google auth inside gemini-cli. If you set a gemini key, by using GEMINI_API_KEY, it will not be free (even if you previously with google auth)

### Opencode CLI
****
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


## Notes on underlying Framework: Stella

IATools leverages the **Stella** framework for its core functionality. Stella provides the infrastructure for application structure, environment isolation, and package management. **Package Management**: Stella uses a concept of "Features" (software packages) which are defined by "Recipes" (Bash scripts). `iatools` uses this system to provide all the tools it manages. The recipes are located in `pool/stella/nix/pool/feature-recipe/`.


## TODO

* llxprt : gemini-cli fork : https://github.com/acoliver/llxprt-code
* kilocode and roocode can use gemini-cli as LLM provider
* kilocode vsextension config home : $HOME/.vscode-server/data/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json
* LiteLLM and gemini-cli https://docs.litellm.ai/docs/tutorials/litellm_gemini_cli
* process manager goreman https://github.com/mattn/goreman
