#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/switch_git_account.sh [haozhexing|Haozhe-Xing]

Examples:
  ./scripts/switch_git_account.sh haozhexing
  ./scripts/switch_git_account.sh Haozhe-Xing

说明：
  该脚本只修改当前仓库的本地 Git 配置，不会修改全局 Git 配置。
EOF
}

ensure_inside_git_repo() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "错误：当前目录不在 Git 仓库内。" >&2
    exit 1
  fi
}

choose_account_interactively() {
  cat <<'EOF'
请选择本地 Git 账号：
  1) haozhexing
  2) Haozhe-Xing
EOF

  read -r -p "输入序号或账号名: " choice

  case "$choice" in
    1|haozhexing)
      echo "haozhexing"
      ;;
    2|Haozhe-Xing)
      echo "Haozhe-Xing"
      ;;
    *)
      echo "错误：不支持的账号选择：$choice" >&2
      exit 1
      ;;
  esac
}

apply_account() {
  local account="$1"
  local name=""
  local email=""

  case "$account" in
    haozhexing)
      name="haozhexing"
      email="haozhexing@tencent.com"
      ;;
    Haozhe-Xing)
      name="Haozhe-Xing"
      email="983189637@qq.com"
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      echo "错误：不支持的账号：$account" >&2
      usage >&2
      exit 1
      ;;
  esac

  git config --local user.name "$name"
  git config --local user.email "$email"

  echo "已切换当前仓库的本地 Git 账号："
  echo "  user.name  = $(git config --local user.name)"
  echo "  user.email = $(git config --local user.email)"
}

main() {
  ensure_inside_git_repo

  local account="${1:-}"
  if [[ -z "$account" ]]; then
    account="$(choose_account_interactively)"
  fi

  apply_account "$account"
}

main "$@"
