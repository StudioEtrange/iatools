# IATools

This project provides a set of tools to interact with generative AI models.

- [IATools](#iatools)
  - [Requirements](#requirements)
  - [Commands](#commands)
  - [gemini-cli](#gemini-cli)
  - [opencode cli](#opencode-cli)
  - [MCP servers](#mcp-servers)
    - [MCP desktop commander](#mcp-desktop-commander)
    - [MCP Server Calculator](#mcp-server-calculator)
    - [Context7 MCP Server](#context7-mcp-server)
    - [GitHub's official MCP Server](#githubs-official-mcp-server)
  - [TODO](#todo)


## Requirements

* bash, git

## Commands

The `iatools <commands>` script provides the following commands:

| Commande | Description |
|----------|-------------|
| **init** | Install dependencies |
| **help** | Display this help message |
| **shell** | Enter iatools context and path |
| **gc install** | Install and configure Gemini CLI *(if asked to relaunch, use `iatools gc launch`)* |
| **gc uninstall** | Uninstall Gemini CLI *(keeps config; use `iatools gc reset` to remove it)* |
| **gc configure** | Configure Gemini CLI *(included in `gc install`)* |
| **gc reset** | Reset all Gemini CLI configuration |
| **gc launch [context folder] -- <options>** | Launch Gemini CLI |
| **gc mcp-context7 install \| uninstall** | Add/remove mcp-context7 local server configuration |
| **gc mcp-calculator install \| uninstall** | Add/remove mcp-calculator local server configuration |
| **gc mcp-desktop-commander install \| uninstall** | Add/remove mcp-desktop-commander local server configuration |
| **gc mcp-github install \| uninstall** | Add/remove mcp-github remote server configuration |
| **oc install** | Install and configure Opencode |
| **oc uninstall** | Uninstall Opencode *(keeps config; use `iatools oc reset` to remove it)* |
| **oc configure** | Configure Opencode *(included in `oc install`)* |
| **oc reset** | Reset all Opencode configuration |
| **oc launch [context folder] -- <options>** | Launch Opencode |
| **oc mcp-context7 install \| uninstall** | Add/remove mcp-context7 local server configuration |
| **oc mcp-calculator install \| uninstall** | Add/remove mcp-calculator local server configuration |
| **oc mcp-github install \| uninstall** | Add/remove mcp-github remote server configuration |

## gemini-cli

```An open-source AI agent that brings the power of Gemini directly into your terminal.```

* website : https://google-gemini.github.io/gemini-cli
* source code : https://github.com/google-gemini/gemini-cli

* IDE integration : 
  * When you run Gemini CLI inside a supported editor, it will automatically detect your environment and prompt you to connect.
  * Manual installation : use `/ide install` - if you install vscode extension with /ide install and have problem, just close and relaunch vscode
  * Other Manual Installation : https://marketplace.visualstudio.com/items?itemName=Google.gemini-cli-vscode-ide-companion

* saved chat history is in $HOME/.gemini/tmp

## opencode cli

```AI coding agent, built for the terminal.```

* website : https://opencode.ai
* source code : https://github.com/sst/opencode

* opencode integrates with VS Code, Cursor, or any IDE that supports a terminal.
  * Open VS Code, Open the integrated terminal, Run opencode : the extension installs automatically
  * Manual installation : https://marketplace.visualstudio.com/items?itemName=sst-dev.opencode

* First steps, init IA provider : `opencode auth login`


## MCP servers

* MCP servers Catalogs : 
  * https://mcpmarket.com/ : Directory of awesome MCP servers and clients to connect AI agents with your favorite tools.
  * https://www.pulsemcp.com/servers?sort=popular-total-desc : MCP Server Directory
  * https://mcpservers.org/ : Awesome MCP Servers - A collection of servers for the Model Context Protocol.

### MCP desktop commander

```This is MCP server for Claude that gives it terminal control, file system search and diff file editing capabilities```

* source code : https://github.com/wonderwhy-er/desktopcommandermcp
* in catalogs :
  * https://www.pulsemcp.com/servers/wonderwhy-er-desktop-commander
  * https://mcpmarket.com/server/desktop-commander-1

### MCP Server Calculator

```A Model Context Protocol server for calculating```

* source code : https://github.com/githejie/mcp-server-calculator
* in catalogs :
  * https://mcpservers.org/servers/githejie/mcp-server-calculator


### Context7 MCP Server

```Fetches up-to-date documentation and code examples for LLMs and AI code editors directly from the source.``` 

* website : https://context7.com/
* source code : https://github.com/upstash/context7
* in catalogs :
  * https://mcpmarket.com/server/context7-1


### GitHub's official MCP Server

```Integration with GitHub Issues, Pull Requests, and more.```

* source code : https://github.com/github/github-mcp-server
* in catalogs :
  * https://www.pulsemcp.com/servers/github

* The GitHub MCP Server connects AI tools directly to GitHub's platform. This gives AI agents, assistants, and chatbots the ability to read repositories and code files, manage issues and PRs, analyze code, and automate workflows. All through natural language interactions.

* The remote GitHub MCP Server is hosted by GitHub and provides the easiest method for getting up and running. If your MCP host does not support remote MCP servers, don't worry! You can use the local version of the GitHub MCP Server instead.


## TODO

* llxprt : gemini-cli fork : https://github.com/acoliver/llxprt-code