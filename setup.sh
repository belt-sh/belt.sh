#!/usr/bin/env bash
set -e

export BELT_REPO="https://github.com/belt-project/belt.sh"
export BELT_VERSION="master"

export BELT_PATH_PREFIX="${BELT_ENV_PATH_PREFIX:-"/usr/local/lib"}"
export BELT_PATH="$BELT_PATH_PREFIX/belt/$BELT_VERSION"

export BELT_TOOLBOX_REPO="${BELT_ENV_TOOLBOX_REPO:-"https://github.com/belt-project/toolbox"}"
export BELT_TOOLBOX_TOOLS="$BELT_ENV_TOOLBOX_TOOLS"

export BELT_TOOLBOX_PATH="$BELT_PATH_PREFIX/belt/toolbox"

bootstrap_abort() {
	local msg="$1"
	echo "belt: $msg"
	exit 1
}

bootstrap_clone() {
	echo "Cloning belt.sh..."
	git clone -b "$BELT_VERSION" "$BELT_REPO" "$BELT_PATH" &>/dev/null || bootstrap_abort "git clone failed for belt"
}

bootstrap_update() {
	echo "Updating belt.sh..."
	git -C "$BELT_PATH" pull &>/dev/null || bootstrap_abort "git pull failed for belt"
}

bootstrap_toolbox_clone() {
	echo "Cloning toolbox..."
	git clone "$BELT_TOOLBOX_REPO" "$BELT_TOOLBOX_PATH" &>/dev/null || bootstrap_abort "git clone failed for toolbox"
}

bootstrap_toolbox_update() {
	echo "Updating toolbox..."
	git -C "$BELT_TOOLBOX_PATH" pull &>/dev/null || bootstrap_abort "git pull failed for toolbox"
}

bootstrap() {
	if [[ ! -x "$(command -v git)" ]]; then
		bootstrap_abort "git not found"
	fi

	if [[ -d "$BELT_LIB" ]]; then
		if [[ "$BELT_VERSION" = "master" || ! "$BELT_VERSION" =~ ^v ]]; then
			echo "Updating belt.sh..."
			bootstrap_update
		fi
	fi

	if [[ ! -d "$BELT_PATH" ]]; then
		bootstrap_clone
	fi

	if [[ -n "$BELT_TOOLBOX_TOOLS" ]]; then
		if [[ -d "$BELT_TOOLBOX_PATH" ]]; then
			bootstrap_toolbox_update
		fi

		if [[ ! -d "$BELT_TOOLBOX_PATH" ]]; then
			bootstrap_toolbox_clone
		fi
	fi
}

bootstrap

# shellcheck disable=SC1090
source "$BELT_PATH/belt.sh"
