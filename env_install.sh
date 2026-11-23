
VENV_DIR="$HOME/.venvs/jupyter"

# Prints a message with a blank line before and after, for readable output.
pretty_print() {
    printf '\n%s\n\n' "$1"
}

# Maps the OSTYPE variable (set by bash) to a short name we can branch on.
detect_os() {
    case "$OSTYPE" in
        linux*)  echo "linux" ;;
        darwin*) echo "macos" ;;
        *)       echo "unsupported" ;;
    esac
}

# Runs a command and stops the script with a clear message if it fails.
run() {
    "$@"
    local status=$?
    if [ "$status" -ne 0 ]; then
        pretty_print "ERROR: '$*' failed with exit code $status"
        exit "$status"
    fi
}

# Installs packages with the right package manager for this OS.
# Usage: install_package <os> <package> [<package> ...]
install_package() {
    local os="$1"
    shift
    case "$os" in
        linux)
            run sudo apt-get update
            run sudo apt-get install -y "$@"
            ;;
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                pretty_print "Homebrew is missing. Install it from https://brew.sh and run this script again."
                exit 1
            fi
            run brew install "$@"
            ;;
    esac
}

ensure_python() {
    local os="$1"
    if command -v python3 >/dev/null 2>&1; then
        pretty_print "python3 found: $(python3 --version)"
        return
    fi
    pretty_print "python3 not found. Installing..."
    case "$os" in
        linux) install_package linux python3 ;;
        macos) install_package macos python ;;
    esac
}

ensure_pip() {
    local os="$1"
    if python3 -m pip --version >/dev/null 2>&1; then
        pretty_print "pip found: $(python3 -m pip --version)"
        return
    fi
    pretty_print "pip not found. Installing..."
    case "$os" in
        linux) install_package linux python3-pip ;;
        macos) pretty_print "pip should come with Homebrew Python. Try: brew reinstall python" ;;
    esac
}

ensure_jupyter() {
    local os="$1"
    if [ -x "$VENV_DIR/bin/jupyter" ]; then
        pretty_print "Jupyter is already installed in $VENV_DIR"
        return
    fi
    # On Debian/Ubuntu the venv module ships in a separate package.
    if [ "$os" = "linux" ]; then
        install_package linux python3-venv
    fi
    pretty_print "Creating a virtual environment and installing Jupyter..."
    run python3 -m venv "$VENV_DIR"
    run "$VENV_DIR/bin/pip" install --upgrade pip notebook
    pretty_print "Jupyter installed. Start it with: $VENV_DIR/bin/jupyter notebook"
}

check_brew_health() {
    pretty_print "Running brew doctor..."
    # brew doctor exits non-zero when it finds warnings, so don't stop the script here.
    brew doctor || pretty_print "brew doctor reported warnings. Read them above."
}

main() {
    local os
    os="$(detect_os)"
    if [ "$os" = "unsupported" ]; then
        pretty_print "Unsupported system: $OSTYPE. Use Linux, macOS or WSL."
        exit 1
    fi
    pretty_print "Detected OS: $os ($OSTYPE)"

    ensure_python "$os"
    ensure_pip "$os"
    ensure_jupyter "$os"

    if [ "$os" = "macos" ]; then
        check_brew_health
    fi

    pretty_print "Setup complete."
}

main "$@"
