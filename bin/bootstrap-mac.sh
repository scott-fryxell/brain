#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 [--skip-node] [--skip-rust] [--skip-npm-install] [--nvim-repo <url>]"
  echo "  or:  NVIM_CONFIG_REPO=<git-url> $0"
  echo "  Run from repo: ./scripts/bootstrap-mac.sh"
  exit 1
}

skip_node=false
skip_rust=false
skip_npm_install=false
nvim_repo="${NVIM_CONFIG_REPO:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-node) skip_node=true; shift ;;
    --skip-rust) skip_rust=true; shift ;;
    --skip-npm-install) skip_npm_install=true; shift ;;
    --nvim-repo)
      [[ $# -ge 2 ]] || usage
      nvim_repo="$2"
      shift 2
      ;;
    -h | --help) usage ;;
    *) usage ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
brewfile="${repo_root}/Brewfile"

ensure_brew_on_path() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi
  if [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi
  return 1
}

install_brew_if_needed() {
  if ensure_brew_on_path; then
    return 0
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ensure_brew_on_path || {
    echo "Homebrew installed but not on PATH; open a new terminal or run brew shellenv" >&2
    exit 1
  }
}

install_brew_if_needed

if [[ ! -f "$brewfile" ]]; then
  echo "missing Brewfile at ${brewfile}" >&2
  exit 1
fi

brew bundle --file="$brewfile"

brew_prefix="$(brew --prefix)"
export NVM_DIR="${HOME}/.nvm"
mkdir -p "$NVM_DIR"

if [[ "$skip_node" == false ]] && [[ -s "${brew_prefix}/opt/nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "${brew_prefix}/opt/nvm/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
fi

if [[ "$skip_rust" == false ]] && ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck source=/dev/null
  [[ -f "${HOME}/.cargo/env" ]] && . "${HOME}/.cargo/env"
fi

if [[ "$skip_npm_install" == false ]] && [[ -f "${repo_root}/package.json" ]] && command -v npm >/dev/null 2>&1; then
  (cd "$repo_root" && npm install)
fi

nvim_config_dir="${HOME}/.config/nvim"
if [[ -n "$nvim_repo" ]]; then
  mkdir -p "${HOME}/.config"
  if [[ -d "${nvim_config_dir}/.git" ]]; then
    echo "bootstrap-mac: ${nvim_config_dir} already a git repo; skipping nvim clone"
  elif [[ -e "$nvim_config_dir" ]]; then
    echo "bootstrap-mac: ${nvim_config_dir} exists (not an empty clone target); skipping nvim clone" >&2
  else
    git clone "$nvim_repo" "$nvim_config_dir"
    echo "bootstrap-mac: cloned nvim config → ${nvim_config_dir} (run nvim once for Lazy)"
  fi
fi

cat <<'EOF'

bootstrap-mac: done (brew + bundle + optional node/rust/npm + optional nvim config).

do manually:
  - Xcode CLT if brew asked: xcode-select --install
  - review ~/.zshrc (should already be configured)
  - secrets: never copy API keys; use ~/.anotht-agent/.env (see .env.example)
  - GOOGLE_APPLICATION_CREDENTIALS / gcloud: gcloud auth application-default login or secure copy of JSON
  - optional casks: edit Brewfile (docker, ghostty, iterm2, google-cloud-sdk) then brew bundle
  - Ollama models: ollama pull nomic-embed-text && ollama pull llama3.2  (see docs/local-setup.md)
  - Pi: cd repo && npm start
  - nvim: if you did not pass --nvim-repo / NVIM_CONFIG_REPO, clone your config to ~/.config/nvim
EOF
