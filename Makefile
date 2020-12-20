ETC_TARGETS = \
	catbox/etc/timezone \
	catbox/etc/localtime \
	catbox/etc/sudoers.d/devas

HOME_TARGETS = \
	catbox/home/devas \
	catbox/home/devas/.gitconfig \
	catbox/home/devas/.gitignore \
	catbox/home/devas/.zshrc \
	catbox/home/devas/.stack \
	catbox/home/devas/.oh-my-zsh \
	catbox/home/devas/.rustup \
	catbox/home/devas/google-cloud-sdk \
	catbox/home/devas/.krew \
	catbox/home/devas/.asdf \
	catbox/home/devas/.asdf/plugins/nodejs \
	catbox/home/devas/.asdf/plugins/yarn \
	catbox/home/devas/.asdf/plugins/python \
	catbox/home/devas/.asdf/plugins/java \
	catbox/home/devas/.asdf/plugins/erlang \
	catbox/home/devas/.asdf/plugins/rebar \
	catbox/home/devas/.asdf/plugins/elixir \
	catbox/home/devas/.asdf/plugins/cmake

DEPS_TARGETS = \
	catbox-apt-essential \
	catbox-apt-opam \
	catbox-apt-golang \
	catbox-apt-cxx \
	catbox-apt-helm \
	catbox-apt-terraform \
	catbox-apt-oci \
	catbox-starship

all: build

.PHONY: build
build: $(ETC_TARGETS) $(DEPS_TARGETS) catbox-locale $(HOME_TARGETS)

.PHONY: catbox
catbox: catbox-working-container
	ln -s $(shell buildah mount catbox-working-container) catbox

.PHONY: catbox-working-container
catbox-working-container:
	buildah from --name catbox-working-container ubuntu:20.10
	buildah config --author="Shikanime Deva" catbox-working-container

.PHONY: catbox-locale
catbox-locale: catbox
	buildah config \
		--env LANG=en_US.UTF-8 \
		--env LANGUAGE=en_US:en \
		--env LC_ALL=en_US.UTF-8 \
		catbox-working-container
	buildah run catbox-working-container \
		locale-gen en_US.UTF-8

.PHONY: catbox-apt
catbox-apt: catbox
	buildah run catbox-working-container \
		apt-get update -y

.PHONY: catbox-apt-essential
catbox-apt-essential: catbox catbox-apt
	buildah run catbox-working-container \
		apt-get install -y --no-install-recommends \
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

.PHONY: catbox-apt-cxx
catbox-apt-cxx: catbox catbox-apt
	buildah run catbox-working-container \
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
			libglu1-mesa-dev

.PHONY: catbox-apt-oci
catbox-apt-oci: catbox catbox-apt
	buildah run catbox-working-container \
		apt-get install -y --no-install-recommends \
			runc \
			podman \
			buildah

.PHONY: catbox-apt-helm
catbox-apt-helm: catbox catbox-apt
	buildah run catbox-working-container -- bash -e <<- EOF
	curl https://baltocdn.com/helm/signing.asc | apt-key add -
	apt-add-repository -y "deb https://baltocdn.com/helm/stable/debian/ all main"
	apt-get install -y --no-install-recommends helm
	EOF

.PHONY: catbox-apt-terraform
catbox-apt-terraform: catbox catbox-apt
	buildah run catbox-working-container -- bash -e <<- EOF
	curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
	apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" && \
	apt-get install -y --no-install-recommends terraform
	EOF

catbox-apt-%: catbox catbox-apt
	buildah run catbox-working-container \
		apt-get install -y --no-install-recommends \
			$@

.PHONY: catbox-starship
catbox-starship: catbox
	buildah run catbox-working-container \
		curl -sSL https://starship.rs/install.sh | bash -s -- -y

catbox/etc/timezone: catbox
	buildah copy catbox-working-container \
		./etc/timezone /etc/timezone

catbox/etc/localtime: catbox
	buildah copy catbox-working-container \
		./etc/localtime /etc/localtime

catbox/etc/sudoers.d/devas: catbox
	buildah copy catbox-working-container \
		./etc/sudoers.d/devas /etc/sudoers.d/devas

catbox/home/devas: catbox
	buildah run catbox-working-container \
		useradd \
			--user-group \
			--create-home \
			--shell /usr/bin/zsh \
			--groups sudo \
			--comment "Shikanime Deva" \
			devas
	buildah config --user devas catbox-working-container

catbox/home/devas/.gitconfig: catbox catbox/home/devas
	buildah copy --chown devas catbox-working-container \
		./home/devas/.gitconfig /home/devas/.gitconfig

catbox/home/devas/.gitignore: catbox catbox/home/devas
	buildah copy --chown devas catbox-working-container \
		./home/devas/.gitignore /home/devas/.gitignore

catbox/home/devas/.zshrc: catbox catbox/home/devas
	buildah copy --chown devas catbox-working-container \
		./home/devas/.zshrc /home/devas/.zshrc

catbox/home/devas/.stack: catbox catbox/home/devas
	buildah run catbox-working-container \
		curl -sSL https: catbox//get.haskellstack.org/ | sh

catbox/home/devas/.oh-my-zsh: catbox catbox/home/devas catbox/home/devas/.zshrc
	buildah run --user devas catbox-working-container -- zsh -i -c "\
		curl -sSL https: catbox//raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s --  --keep-zshrc --skip-chsh"

catbox/home/devas/.rustup: catbox catbox/home/devas
	buildah run --user devas catbox-working-container -- zsh -i -c "\
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

catbox/home/devas/google-cloud-sdk: catbox catbox/home/devas
	buildah run --user devas catbox-working-container -- zsh -i -c "\
		curl https://sdk.cloud.google.com | bash -s -- --disable-prompts"
	buildah run --user devas catbox-working-container -- zsh -i -c "\
		gcloud components install --quiet \
			beta \
			alpha \
			kubectl \
			skaffold \
			kustomize

catbox/home/devas/.krew: catbox catbox/home/devas
	buildah run catbox-working-container -- bash -e <<- EOF
	mkdir -p /tmp/krew-install
	curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" -o /tmp/krew-install/krew.tar.gz
	tar zxvf /tmp/krew-install/krew.tar.gz /tmp/krew-install/krew-linux_amd64
	/tmp/krew-install/krew-linux_amd64 install krew
	rm -rf /tmp/krew-install
	EOF

catbox/home/devas/.asdf: catbox catbox/home/devas
	buildah run --user devas catbox-working-container -- zsh -i -c "\
		git clone https://github.com/asdf-vm/asdf.git /home/devas/.asdf --branch v0.8.0"

catbox/home/devas/.asdf/plugins/nodejs: catbox catbox/home/devas/.asdf
	buildah run --user devas catbox-working-container -- zsh -i -f <<EOF \
	asdf plugin add nodejs \
	bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
	EOF

catbox/home/devas/.asdf/plugins/%: catbox catbox/home/%/.asdf
	buildah run --user devas catbox-working-container -- zsh -i -c "\
		asdf plugin add $@"

.PHONY: commit
commit:
	buildah commit --rm catbox-working-container \
		docker.pkg.github.com/Shikanime/Shikanime/catbox:20.10

.PHONY: clean clean-catbox clean-catbox-working-container
clean: clean-catbox

clean-catbox: clean-catbox-working-container
	rm -f catbox

clean-catbox-working-container:
	buildah rm catbox-working-container
