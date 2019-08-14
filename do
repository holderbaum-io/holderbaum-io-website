#!/bin/bash

set -eu

ensure_ruby() {
  local bundler_version="$(tail -n1 Gemfile.lock |tr -d ' ')"
  if ! gem list -q bundler |grep -q "$bundler_version" >/dev/null;
  then
    gem install "bundler:$bundler_version"
  fi
  bundle install --path vendor/bundle --binstubs vendor/bin
}

function prepare_ci {
  return 0
  export encrypted_9e05e58bd4ea_key
  export encrypted_9e05e58bd4ea_iv
  openssl aes-256-cbc \
    -K "$encrypted_9e05e58bd4ea_key" \
    -iv "$encrypted_9e05e58bd4ea_iv" \
    -in deploy/ssh.enc \
    -out deploy/ssh \
    -d
  chmod 600 deploy/ssh
}

task_serve() {
  ensure_ruby

  local port="${1:-9090}"
  ./vendor/bin/middleman serve -p "$port" --bind-address=127.0.0.1
}

task_build() {
  ensure_ruby

  ./vendor/bin/middleman build
}

task_clean() {
  rm -rf build/
}

task_deploy() {
  prepare_ci
  exit 0
}

usage() {
  echo "$0 serve | build | deploy | clean"
  exit 1
}

cmd="${1:-}"
shift || true
case "$cmd" in
  clean) task_clean ;;
  serve) task_serve "$@" ;;
  build) task_build ;;
  deploy) task_deploy "$@" ;;
  *) usage ;;
esac
