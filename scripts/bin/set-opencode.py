#!/usr/bin/env python3
"""set-opencode: pick the OpenRouter key, base URL and model for opencode.

Keys are read from environment variables (e.g. from ~/.secrets.env); keys
whose variable is not set are not offered.
"""
import json
import os
import shutil
import sys
from pathlib import Path

provider = "openrouter"

# name shown in the menu -> environment variable holding the key
KEY_ENV_VARS = {
    "my-key": "OPENCODE_OPENROUTER_KEY",
    "efrda": "OPENROUTER_EFARDA_KEY",
}
API_KEYS = {name: os.environ[var] for name, var in KEY_ENV_VARS.items() if os.environ.get(var)}
BASE_URLS = {
    "llm-proxy": "https://llm-proxy.open8.ir/openrouter",
    "default-openrouter": "https://openrouter.ai/api/v1",
}
def load_json_file(file_path: Path) -> dict:
    """Load JSON from file, returning empty dict if file doesn't exist."""
    if file_path.exists():
        with open(file_path, 'r') as f:
            return json.load(f)
    return {}

def save_json_file(file_path: Path, data: dict) -> None:
    """Save data to JSON file, creating parent directories if needed."""
    file_path.parent.mkdir(parents=True, exist_ok=True)
    if file_path.exists():
        shutil.copy2(file_path, file_path.with_name(file_path.name + ".bak"))
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2)

def select_from_list(prompt: str, options: dict, default_index: int = 0) -> str:
    """Display a numbered list and return the selected key."""
    print(f"\n{prompt}")
    for idx, name in enumerate(options.keys(), 1):
        suffix = " (default)" if idx - 1 == default_index else ""
        print(f"  {idx}. {name}{suffix}")
    
    while True:
        try:
            choice = input("\nEnter your choice (number) [press Enter for default]: ").strip()
            if choice == "":
                return list(options.keys())[default_index]
            choice = int(choice)
            if 1 <= choice <= len(options):
                return list(options.keys())[choice - 1]
            else:
                print("Invalid selection. Please try again.")
        except ValueError:
            print("Please enter a valid number.")

MODELS = {
    "gpt5.6 luna": "openrouter/openai/gpt-5.6-luna",
    "GLM 5.2" : "openrouter/z-ai/glm-5.2",
    "MiniMax M3": "openrouter/minimax/minimax-m3",
    "Xiaomi MiMo 2.5 Pro": "openrouter/xiaomi/mimo-v2.5-pro",
    "DeepSeek V4 Pro": "openrouter/deepseek/deepseek-v4-pro",
    "Tencent Hy3": "openrouter/tencent/hy3",
}

def override_provider_config():
    """Override {provider} configuration with user-selected API key and base URL."""
    print(f"=== {provider.capitalize()} Configuration Override ===")
    if not API_KEYS:
        sys.exit("No API key found; set one of: " + ", ".join(KEY_ENV_VARS.values()))
    # Select API key
    selected_key_name = select_from_list("Select API Key:", API_KEYS)
    selected_api_key = API_KEYS[selected_key_name]
    # Select base URL
    selected_base_url_name = select_from_list("Select Base URL:", BASE_URLS)
    selected_base_url = BASE_URLS[selected_base_url_name]
    # Select model
    selected_model_name = select_from_list("Select Model:", MODELS)
    selected_model = MODELS[selected_model_name]
    # Define file paths
    data_home = Path(os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share")
    config_home = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    auth_file = data_home / "opencode/auth.json"
    config_file = config_home / "opencode/opencode.json"
    # Load existing data
    auth_data = load_json_file(auth_file)
    config_data = load_json_file(config_file)
    # Update data structures using provider variable
    auth_data.setdefault(provider, {})
    auth_data[provider]["key"] = selected_api_key
    auth_data[provider]["__keyname__"] = selected_key_name
    config_data["model"] = selected_model
    config_data.setdefault("provider", {})
    config_data["provider"].setdefault(provider, {})
    config_data["provider"][provider].setdefault("options", {})
    config_data["provider"][provider]["options"]["baseURL"] = selected_base_url
    # config_data["provider"][provider]["options"]["__baseURL__"] = selected_base_url
    # Save updated data
    save_json_file(auth_file, auth_data)
    save_json_file(config_file, config_data)
    print(f"   Auth file: {auth_file}")
    print(f"   Config file: {config_file}")
    print("\n✅ Configuration updated successfully!")
    print(f"   API Key: {selected_key_name}")
    print(f"   Base URL: {selected_base_url_name}")
    print(f"   Model: {selected_model_name}")

if __name__ == "__main__":
    override_provider_config()
