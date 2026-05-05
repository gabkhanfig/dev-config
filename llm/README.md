# Setup On-Device LLM Server with llama.cpp

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
