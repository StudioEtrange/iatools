
# CLIProxyAPI

CLIProxyAPI is a tool that bridges the gap between command-line interfaces and AI models, enabling seamless integration and interaction.

## Links

  * https://help.router-for.me/
  * https://github.com/router-for-me/CLIProxyAPI
  * https://github.com/router-for-me/CLIProxyAPIPlus
  * Installer project : https://github.com/brokechubb/cliproxyapi-installer

## Quickstart

install
```
./iatools cpa install
```

launch
```
./iatools cpa launch
```

authenticate to gemini cli --
requirements : gemini-cli configured `./iatools gc install`
```
./iatools cpa launch -- --login --no-browser [--project_id <your_project_id>]
```

info
```
./iatools cpa info
```

list endpoints sample test
```
curl -s http://localhost:8317
```

list available models
```
YOUR_TOKEN="xxxx"
curl -X GET "http://localhost:8317/v1/models" \
    -H "Authorization: Bearer $YOUR_TOKEN" \
    -H "Content-Type: application/json"
```

test chat completion
```
curl -X POST http://localhost:8317/v1/chat/completions \
    -H "Authorization: Bearer $YOUR_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "gemini-2.5-pro",
        "messages": [
        {"role": "user", "content": "Hello from test"}
        ]
    }'
```

## Connect  KiloCode VS Code extension 
  
* In KiloCode extension settings
  * API Provider : OpenAI Compatible
  * Base URL : http://127.0.0.1:8317/v1
  * API Key : <YOUR_TOKEN>
  * Model : Kilo Code will load list of available modeles (ex:gemini-2.5-pro)
  * Context Window Size : Get size by selecting API Provider of the proxified LLM (ie: Google Gemini default setup for gemini-2.5-pro is 1048576)
