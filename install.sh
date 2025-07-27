#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status file to track completed steps
STATUS_FILE="$HOME/.dotfiles_install_status"

# Function to log messages
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to mark step as completed
mark_completed() {
    echo "$1" >> "$STATUS_FILE"
}

# Function to check if step is completed
is_completed() {
    [ -f "$STATUS_FILE" ] && grep -q "^$1$" "$STATUS_FILE"
}

# Function to show available steps
show_steps() {
    echo -e "${BLUE}Available installation steps:${NC}"
    echo "1. system_update     - Update system packages"
    echo "2. fish_install      - Install Fish shell"
    echo "3. fisher_install    - Install Fisher and plugins"
    echo "4. fzf_install       - Install fzf"
    echo "5. base16_install    - Install base16-shell"
    echo "6. golang_install    - Install Go (latest version)"
    echo "7. ghq_install       - Install ghq"
    echo "8. symlinks_create   - Create symbolic links"
    echo ""
    echo "Usage: $0 [step_number|step_name|--from step_number|--list|--reset]"
    echo "  --from N    : Start from step N"
    echo "  --list      : Show this help"
    echo "  --reset     : Reset installation status"
}

# Installation steps
step1_system_update() {
    if is_completed "system_update"; then
        success "System update already completed"
        return 0
    fi
    
    log "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    mark_completed "system_update"
    success "System update completed"
}

step2_fish_install() {
    if is_completed "fish_install"; then
        success "Fish shell already installed"
        return 0
    fi
    
    log "Installing Fish shell..."
    sudo add-apt-repository ppa:fish-shell/release-4 -y
    sudo apt update
    sudo apt install -y fish
    mark_completed "fish_install"
    success "Fish shell installed"
}

step3_fisher_install() {
    if is_completed "fisher_install"; then
        success "Fisher and plugins already installed"
        return 0
    fi
    
    log "Installing Fisher and plugins..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    fish -c "fisher install oh-my-fish/theme-bobthefish jethrokuan/fzf decors/fish-ghq jorgebucaran/nvm.fish"
    mark_completed "fisher_install"
    success "Fisher and plugins installed"
}

step4_fzf_install() {
    if is_completed "fzf_install"; then
        success "fzf already installed"
        return 0
    fi
    
    log "Installing fzf..."
    sudo apt install -y fzf
    mark_completed "fzf_install"
    success "fzf installed"
}

step5_base16_install() {
    if is_completed "base16_install"; then
        success "base16-shell already installed"
        return 0
    fi
    
    log "Installing base16-shell..."
    if [ -d ~/.config/base16-shell ]; then
        warning "base16-shell directory already exists, updating..."
        cd ~/.config/base16-shell && git pull
    else
        git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
    fi
    mark_completed "base16_install"
    success "base16-shell installed"
}

step6_golang_install() {
    if is_completed "golang_install"; then
        success "Go already installed"
        return 0
    fi
    
    log "Installing build dependencies..."
    sudo apt install -y build-essential curl
    
    log "Fetching latest Go version..."
    GOLANG_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1 | sed 's/go//')
    if [ -z "$GOLANG_VERSION" ]; then
        error "Failed to fetch Go version"
        return 1
    fi
    
    log "Installing Go ${GOLANG_VERSION}..."
    wget "https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go${GOLANG_VERSION}.linux-amd64.tar.gz"
    rm "go${GOLANG_VERSION}.linux-amd64.tar.gz"
    mark_completed "golang_install"
    success "Go ${GOLANG_VERSION} installed"
}

step7_ghq_install() {
    if is_completed "ghq_install"; then
        success "ghq already installed"
        return 0
    fi
    
    if ! is_completed "golang_install"; then
        error "Go must be installed first. Run step 6 (golang_install)"
        return 1
    fi
    
    log "Installing ghq..."
    /usr/local/go/bin/go install github.com/x-motemen/ghq@latest
    mark_completed "ghq_install"
    success "ghq installed"
}

step8_symlinks_create() {
    if is_completed "symlinks_create"; then
        success "Symbolic links already created"
        return 0
    fi
    
    log "Creating symbolic links..."
    mkdir -p ~/.config/fish/functions
    
    ln -snf "$(pwd)/.bashrc" ~/.bashrc
    ln -snf "$(pwd)/.tmux.conf" ~/.tmux.conf
    ln -snf "$(pwd)/config.fish" ~/.config/fish/config.fish
    ln -snf "$(pwd)/tminimum.fish" ~/.config/fish/functions/tminimum.fish
    
    mark_completed "symlinks_create"
    success "Symbolic links created"
}

# Execute step by number or name
execute_step() {
    case "$1" in
        1|system_update) step1_system_update ;;
        2|fish_install) step2_fish_install ;;
        3|fisher_install) step3_fisher_install ;;
        4|fzf_install) step4_fzf_install ;;
        5|base16_install) step5_base16_install ;;
        6|golang_install) step6_golang_install ;;
        7|ghq_install) step7_ghq_install ;;
        8|symlinks_create) step8_symlinks_create ;;
        *) error "Unknown step: $1"; return 1 ;;
    esac
}

# Main execution logic
main() {
    case "$1" in
        --list|-h|--help)
            show_steps
            exit 0
            ;;
        --reset)
            log "Resetting installation status..."
            rm -f "$STATUS_FILE"
            success "Installation status reset"
            exit 0
            ;;
        --from)
            if [ -z "$2" ]; then
                error "Please specify step number after --from"
                exit 1
            fi
            log "Starting from step $2..."
            for i in $(seq "$2" 8); do
                execute_step "$i" || { error "Step $i failed"; exit 1; }
            done
            ;;
        "")
            log "Running all installation steps..."
            for i in $(seq 1 8); do
                execute_step "$i" || { error "Step $i failed. Use '$0 --from $i' to resume"; exit 1; }
            done
            success "All installation steps completed!"
            ;;
        *)
            execute_step "$1" || { error "Step $1 failed"; exit 1; }
            ;;
    esac
}

# Run main function with all arguments
main "$@"