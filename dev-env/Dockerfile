FROM i386/debian:bookworm

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git zsh curl mc nasm binutils xxd bsdextrautils make ca-certificates; \
    ZSH="/root/.oh-my-zsh" \
    RUNZSH=no \
    CHSH=no \
    KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    rm -rf /var/lib/apt/lists/*

SHELL ["/usr/bin/zsh", "-c"]

WORKDIR /src

CMD ["sleep", "infinity"]
