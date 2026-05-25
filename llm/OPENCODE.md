# Setup OpenCode

[Download OpenCode](https://opencode.ai/).

## Setup OpenCode Config

Open `~/.config/opencode/opencode.json` and paste the following:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "*": "ask",
    "read": "allow",
    "glob": "allow",
    "grep": "allow",
    "list": "allow"
  },
  "provider": {
    "llamacpp-server": {
      "models": {
        "default": {
          "_launch": true,
          "name": "default"
        }
      },
      "name": "gabkhanfig Llama.cpp",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://SERVER_IP/v1"
      }
    }
  }
}
```

Replace SERVER_IP with the actual one.

## Connect API Key

open opencode

```sh
opencode
```

Inside opencode, type `/connect` and press enter. Search for `gabkhanfig Llama.cpp` like in your opencode.json, and then paste your API key.

Enjoy :D.
