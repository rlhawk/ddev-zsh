#ddev-generated

ARG ANTIDOTE_VERSION=v2.3.0
ARG OH_MY_ZSH_COMMIT=9112b53
ARG STARSHIP_VERSION=1.26.0

RUN <<EOF
set -eu

# ------------------------------------------------------------------
# Antidote
# ------------------------------------------------------------------

git clone \
  --branch "${ANTIDOTE_VERSION}" \
  --depth=1 \
  https://github.com/mattmc3/antidote.git \
  /usr/local/share/antidote

# ------------------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------------------

git clone \
  https://github.com/ohmyzsh/ohmyzsh.git \
  /usr/local/share/oh-my-zsh

cd /usr/local/share/oh-my-zsh
git checkout "${OH_MY_ZSH_COMMIT}"

# ------------------------------------------------------------------
# Starship
# ------------------------------------------------------------------

case "$(uname -m)" in
  x86_64)
    STARSHIP_ARCH=x86_64-unknown-linux-musl
    ;;
  aarch64|arm64)
    STARSHIP_ARCH=aarch64-unknown-linux-musl
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)"
    exit 1
    ;;
esac

curl -fsSL \
  "https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-${STARSHIP_ARCH}.tar.gz" \
  -o /tmp/starship.tar.gz

tar -xzf /tmp/starship.tar.gz -C /tmp

install -m 0755 \
  /tmp/starship \
  /usr/local/bin/starship

rm -f /tmp/starship
rm -f /tmp/starship.tar.gz

# ------------------------------------------------------------------
# Permissions
# ------------------------------------------------------------------

chmod -R a+rX \
  /usr/local/share/antidote \
  /usr/local/share/oh-my-zsh

# ------------------------------------------------------------------
# Verification
# ------------------------------------------------------------------

command -v zsh
command -v fzf
command -v starship

test -r /usr/local/share/antidote/antidote.zsh
test -r /usr/local/share/oh-my-zsh/oh-my-zsh.sh

EOF
