# Setup On-Device LLM Server with llama.cpp

## Make LLM user

Create a dedicated `llama` user that owns the llama.cpp checkout, the model files,
and the API key file. The systemd service will run as this user.

```sh
# Create user with a home directory and bash shell
sudo useradd -m -s /bin/bash llama

# Grant GPU device access
#   - render: ROCm/DRM compute device nodes (/dev/dri/renderD*)
#   - video:  GPU device nodes (/dev/dri/card*, /dev/kfd on AMD)
sudo usermod -aG render,video llama
```

Then switch into the `llama` user for the rest of the setup (build, key file, etc.):

```sh
sudo -iu llama
```

Verify GPU access from the new user shell before continuing:

```sh
# AMD: should list your GPU
rocminfo | grep -i 'gfx\|Name'
# NVIDIA: should list your GPU
nvidia-smi
```

If `rocminfo` reports no agents or `/dev/kfd` permission errors, log the `llama`
user fully out and back in (or reboot) so the new group memberships take effect.

## Building llama.cpp

### 1. Get Repo

```sh
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
```

### 2. CMake Configure for Platform

```sh
# For NVidia GPU:
cmake -B build -DCMAKE_BUILD_TYPE=Release -DLLAMA_CUDA=ON
# For AMD GPU:
rocminfo
# find the gfx 4 digit number, like 1201, to use for NNNN
cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_HIP=ON -DAMDGPU_TARGETS=gfxNNNN

# For Mac:
cmake -B build -DCMAKE_BUILD_TYPE=Release

# For Vulkan:
# https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#vulkan
cmake -B build -DGGML_VULKAN=ON
```

### 3. CMake Build

```sh
cmake --build build --config Release
```

## Try Run Inference Server

```sh
HIP_VISIBLE_DEVICES=0 ROCR_VISIBLE_DEVICES=0 \
build/bin/llama-server \
--model ~/Downloads/Qwen3.6-27B-Q4_K_M.gguf \
--host 0.0.0.0 \
--port 11433 \
--ctx-size 131072 \
--n-gpu-layers 99
```

## Setup Systemd Service

### 1. Setup API Key

```sh
nano ~/llama-keys.txt
```

Set the API key, doesn't matter what.

### 2. Set Systemd Service File

```sh
sudo nano /etc/systemd/system/llama-server.service
```

Paste the contents of the [llama-server.service](/llm/llama-server.service) file.
Adjust the `User=`, `WorkingDirectory=`, `--model`, and `--api-key-file` paths
to match your install. Drop the `HIP_VISIBLE_DEVICES` / `ROCR_VISIBLE_DEVICES`
lines if you're not on AMD.

### 3. Reload, Enable, and Start

```sh
sudo systemctl daemon-reload && \
sudo systemctl enable llama-server && \
sudo systemctl start llama-server
```

### 4. Verify

```sh
# Service status
sudo systemctl status llama-server

# Follow live logs
sudo journalctl -fu llama-server

# Smoke test the endpoint (replace YOUR_KEY with a key from llama-keys.txt)
curl http://localhost:11433/v1/chat/completions \
-H "Authorization: Bearer YOUR_KEY" \
-H "Content-Type: application/json" \
-d '{"messages":[{"role":"user","content":"hi"}]}'

curl http://mineral-pause.with.playit.plus:1447/v1/chat/completions -H "Authorization: Bearer SCOTT_OPENCODE_KEY_POO" -H "Content-Type: application/json" -d '{"messages":[{"role":"user","content":"hi"}]}'

# And this one should not work
curl http://localhost:11433/v1/chat/completions \
-H "Authorization: Bearer WRONG_KEY" \
-H "Content-Type: application/json" \
-d '{"messages":[{"role":"user","content":"hi"}]}'
```

### 5. Updating the Service

After editing `/etc/systemd/system/llama-server.service`:

```sh
sudo systemctl daemon-reload
sudo systemctl restart llama-server
```

## Setup OpenCode

[Download OpenCode](https://opencode.ai/).

### Setup OpenCode Config

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
        "qwen3.6:27b": {
          "_launch": true,
          "name": "qwen3.6:27b"
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

### Connect API Key

open opencode

```sh
opencode
```

Inside opencode, type `/connect` and press enter. Search for `gabkhanfig Llama.cpp` like in your opencode.json, and then paste your API key.

Enjoy :D.
