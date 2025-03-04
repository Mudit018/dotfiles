# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# prompt option 1
source ~/.bash_custom

# initialize starship -- prompt option 2
eval "$(starship init bash)"

# Proxy configuration
enable_proxy() {
    username="username"
    password="password"
    ipaddr="x.x.x.x"
    port="8080"
    proxy_url="http://$username:$password@$ipaddr:$port"
    proxy_url_noauth="http://$ipaddr:$port"

    export HTTP_PROXY="$proxy_url"
    export HTTPS_PROXY="$proxy_url"
    export http_proxy="$proxy_url"
    export https_proxy="$proxy_url"

    # For apt package manager
    echo "Acquire::http::Proxy \"$proxy_url\";Acquire::https::Proxy \"$proxy_url\";" > proxy.conf
    sudo cp ~/proxy.conf /etc/apt/apt.conf.d/
    rm ~/proxy.conf

    # For dnf package manager
    echo "[main]\nproxy=\"$proxy_url\"" > dnf.conf
    sudo cp ~/dnf.conf /etc/dnf/

    # Snap package manager
    sudo snap set system proxy.http="$proxy_url_noauth"
    sudo snap set system proxy.https="$proxy_url_noauth"

    # maven
    if [ -f ~/.maven/settings-proxy.xml ]; then
        sudo cp ~/.maven/settings-proxy.xml /etc/maven/settings.xml
    fi
}

disable_proxy() {
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset http_proxy
    unset https_proxy

    # For apt package manager
    if [ -f /etc/apt/apt.conf.d/proxy.conf ]; then
        sudo rm /etc/apt/apt.conf.d/proxy.conf
    fi
    if [ -f ~/proxy.conf ]; then
        rm ~/proxy.conf
    fi

    # For dnf package manager
    if [ -f /etc/dnf/dnf.conf ]; then
        sudo rm /etc/dnf/dnf.conf
    fi
    if [ -f ~/dnf.conf ]; then
        rm ~/dnf.conf
    fi

    # Snap package manager
    sudo snap unset system proxy.http
    sudo snap unset system proxy.https

    # maven
    if [ -f ~/.maven/settings.xml ]; then
        sudo cp ~/.maven/settings.xml /etc/maven/settings.xml
    fi
}
