FROM ubuntu:20.10

LABEL maintainer="deva.shikanime@protonmail.com"

# Setup timezone
COPY etc/timezone /etc/timezone
COPY etc/localtime /etc/localtime

# Install system packages
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
			build-essential \
			clang-format \
			clang-tidy \
			clang-tools \
			clang \
			libc++-dev \
			libc++1 \
			libc++abi-dev \
			libc++abi1 \
			libclang-dev \
			libclang1 \
			libomp-dev \
			libomp5 \
			lld \
			lldb \
			llvm-dev \
			llvm-runtime \
			llvm \
			ninja-build \
			xorg-dev \
			mesa-utils \
			libglu1-mesa-dev \
			runc \
			podman \
			buildah \
			locales \
			libssl1.1 \
			apt-utils \
			git \
			openssh-client \
			gnupg2 \
			inotify-tools \
			neovim \
			iproute2 \
			procps \
			lsof \
			htop \
			net-tools \
			psmisc \
			curl \
			wget \
			rsync \
			ca-certificates \
			unzip \
			software-properties-common \
			zip \
			nano \
			vim-tiny \
			less \
			jq \
			lsb-release \
			apt-transport-https \
			dialog \
			libc6 \
			libgcc1 \
			libkrb5-3 \
			libgssapi-krb5-2 \
			libicu-dev \
			liblttng-ust0 \
			libstdc++6 \
			zlib1g \
			sudo \
			ncdu \
			man-db \
			strace \
			libbz2-dev \
			libsqlite3-dev \
			m4 \
			libreadline-dev \
			libncurses-dev \
			libssh-dev \
			libyaml-dev \
			libxslt1-dev \
			libffi-dev \
			libncurses5-dev \
			libtool \
			unixodbc-dev \
			libwxgtk3.0-gtk3-dev \
			libgl1-mesa-dev \
			libglu1-mesa-dev \
			libpng-dev \
			libssl-dev \
			automake \
			autoconf \
			libxml2-utils \
			xsltproc \
			zsh \
			fop

# Helm
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && \
  apt-add-repository -y "deb https://baltocdn.com/helm/stable/debian/ all main" && \
  apt-get install -y --no-install-recommends helm

# Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
  apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" && \
  apt-get install -y --no-install-recommends terraform

# Haskell development tools
RUN curl -sSL https://get.haskellstack.org/ | sh

# Install Starship
RUN curl -sSL https://starship.rs/install.sh | bash -s -- -y

# Setup locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Switch to user space
RUN useradd \
  --user-group \
  --create-home \
  --shell /usr/bin/zsh \
  --groups sudo \
  --comment "Shikanime Deva" \
  devas
COPY etc/sudoers.d/devas /etc/sudoers.d
USER devas

# Install Oh My ZSH
RUN zsh -i -c "curl -sSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s --  --keep-zshrc --skip-chsh"

# Install ASDF
RUN zsh -i -c "git clone https://github.com/asdf-vm/asdf.git /home/devas/.asdf --branch v0.8.0"

# Configure NodeJS development tools
RUN zsh -i -c "asdf plugin add nodejs" && \
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
RUN zsh -i -c "asdf plugin add yarn"

# Configure Python development tools
RUN zsh -i -c "asdf plugin add python"

# Configure Java development tools
RUN zsh -i -c "asdf plugin add java"

# Configure BEAM development tools
RUN zsh -i -c "asdf plugin add erlang && \
  asdf plugin add rebar && \
  asdf plugin add elixir"

# Configure CPP development tools
RUN zsh -i -c "asdf plugin add cmake"

# Install Rust development tools
RUN zsh -i -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

# Install Google Cloud tools
RUN zsh -i -c "curl https://sdk.cloud.google.com | bash -s -- --disable-prompts"
RUN zsh -i -c "gcloud components install --quiet \
  beta \
  alpha"

# Install Kubernetes tools
RUN zsh -i -c "gcloud components install --quiet \
  kubectl \
  skaffold \
  kustomize"

# Install Krew package manager
RUN mkdir -p /tmp/krew-install && \
  cd /tmp/krew-install && \
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" && \
  tar zxvf krew.tar.gz ./krew-linux_amd64 && \
  ./krew-linux_amd64 install krew && \
  rm -rf /tmp/krew-install

# Add user configuration
COPY --chown=devas home/devas/.gitconfig /home/devas/.gitconfig
COPY --chown=devas home/devas/.gitignore /home/devas/.gitignore
COPY --chown=devas home/devas/.zshrc /home/devas/.zshrc

# Command entrypoint
ENTRYPOINT [ "/usr/bin/zsh" ]
