{ config, pkgs, ... }:
let
  inherit (pkgs.hax) isDarwin isLinux fetchFromGitHub;

  # name stuff
  username = "jamievandyke";
  awsusername = "ec2-user";
  name = "Jamie van Dyke";
  personalEmail = "jamie@fearoffi.sh";
  workEmail = "jamie@tetra.team";

  onAws = builtins.getEnv "USER" == awsusername;
  promptChar = if isDarwin then "ᛗ" else "ᛥ";
  # chief keefs stuff
  # fearoffish-cfg = import (
  #   fetchFromGitHub {
  #     owner = "fearoffish";
  #     repo = "cfg";
  #     rev = "";
  #     sha256 = "";
  #   }
  # );

in
  with pkgs.hax; {
    nixpkgs.overlays = import ./overlays.nix;
    nixpkgs.config = { allowUnfree = true; };
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
    programs.htop.enable = true;
    programs.dircolors.enable = true;
    programs.zsh.enable = true

    home = {
      username =
        if isDarwin then
          "${username}"
        else
        (if onAws then awsusername else username);
      homeDirectory =
        if isDarwin then
          "/Users/${username}"
        else
          (if onAws then "/home/${awsusername}" else "/home/${username}");
      stateVersion = "21.11";

      sessionVariables = {
        EDITOR = "lvim";
        HISTCONTROL = "ignoreboth";
        PAGER = "less";
        LESS = "-iR";
      };

      packages = with pkgs;
        lib.flatten [
          awscli2
          amazon-ecr-credential-helper
          atool
          bat
          bc
          bzip2
          cacert
          cachix
          cloudquery
          coreutils-full
          cowsay
          curl
          dasel
          diffutils
          dos2unix
          ed
          exa
          fd
          figlet
          file
          gawk
          gcc
          gitAndTools.delta
          gnugrep
          gnupg
          gnused
          gnumake
          gnutar
          gron
          gzip
          hadolint
          htop
          jq
          just
          kubectx
          less
          libarchive
          libnotify
          lolcat
          loop
          lsof
          man-pages
          minikube
          moreutils
          nano
          ncdu
          netcat-gnu
          nixUnstable
          nix-zsh-completions
          nix-index
          nix-info
          nix-prefetch-github
          nix-prefetch-scripts
          nix-tree
          nixpkgs-fmt
          nmap
          openssh
          ossutil
          p7zip
          patch
          perl
          php
          pigz
          procps
          pssh
          pup
          pv
          ranger
          rare
          re2c
          ripgrep
          ripgrep-all
          rlwrap
          rnix-lsp
          rsync
          scc
          sd
          shellcheck
          shfmt
          socat
          sox
          swaks
          time
          tealdeer
          unzip
          watch
          watchexec
          wget
          which
          xxd
          yq-go
          zip
          # kwbauson-cfg.better-comma
          # kwbauson-cfg.nle
          # kwbauson-cfg.git-trim
          # (
          #   writeBashBinChecked "hms" ''
          #     git -C ~/.config/nixpkgs/ pull origin main
          #     home-manager switch
          #   ''
          # )
          # (
          #   writeBashBinChecked "get_cert" ''
          #     curl --insecure -I -vvv "$1" 2>&1 |
          #       awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
          #   ''
          # )
          # (
          #   writeBashBinChecked "ecr_login" ''
          #     region="''${1:-us-east-1}"
          #     aws ecr get-login-password --region "''${region}" |
          #     docker login --username AWS \
          #         --password-stdin "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.''${region}.amazonaws.com"
          #   ''
          # )
          # (
          #   writeBashBinChecked "ecr_login_public" ''
          #     region="''${1:-us-east-1}"
          #     aws ecr-public get-login-password --region "''${region}" |
          #     docker login --username AWS \
          #         --password-stdin public.ecr.aws
          #   ''
          # )
          (
            writeBashBinChecked "jql" ''
              echo "" | fzf --print-query --preview-window wrap --preview "cat $1 | jq -C {q}"
            ''
          )
          (
          #   writeBashBinChecked "slack_meme" ''
          #     word="$1"
          #     fg="$2"
          #     bg="$3"
          #     figlet -f banner "$word" | sed 's/#/:'"$fg"':/g;s/ /:'"$bg"':/g' | awk '{print ":'"$bg"':" $1}'
          #   ''
          # )
          # (
          #   writeBashBinChecked "ssh_fwd" ''
          #     host="$1"
          #     port="$2"
          #     ssh -L "$port:$host:$port" "$host"
          #   ''
          # )
          # (
          #   writeBashBinChecked "nix_hash_unstable" ''
          #     ${nix-prefetch-git}/bin/nix-prefetch-git \
          #       --quiet \
          #       --no-deepClone \
          #       --branch-name nixpkgs-unstable \
          #       https://github.com/NixOS/nixpkgs.git | \
          #     ${jq}/bin/jq -r '.rev,.sha256' 
          #   ''
          # )
          (
            lib.optional isLinux [
              binutils
              (python39.withPackages (pkgs: with pkgs; [ black mypy flake8 bpython ]))
              keybase
              (
                writeBashBinChecked "u" ''
                  sudo apt update
                  sudo apt upgrade
                ''
              )
            ]
          )
        ];
    };

    programs.zsh = {
      enable = true;
      inherit (config.home) sessionVariables;
      historyFileSize = -1;
      historySize = -1;
      shellAliases = {
        ",," = "nix run github:kwbauson/cfg#better-comma -- ";
        ls = "ls --color=auto";
        l = "exa -alFT -L 1";
        ll = "ls -ahlFG";
        mkdir = "mkdir -pv";
        ncdu = "ncdu --color dark -ex";
        hm = "home-manager";
        wrun =
          "watchexec --debounce 50 --no-shell --clear --restart --signal SIGTERM -- ";
        fzfp = "fzf --preview 'bat --style=numbers --color=always {}'";
        strip = ''
          sed -E 's#^\s+|\s+$##g'
        '';

        # nix
        nix_hash = "nix-prefetch-url";
        nix_hash_git = "nix-prefetch-git";
        nix_hash_kwb = "nix-prefetch-git https://github.com/kwbauson/cfg.git";

        # git
        g = "git";
        ga = "git add -A .";
        cm = "git commit -m ";

        # docker
        d = "docker";
        da = "docker ps -a";
        di = "docker images";
        de = "docker exec -it";
        dr = "docker run --rm -it";
        drma = "docker stop $(docker ps -aq) && docker rm -f $(docker ps -aq)";
        drmi = "di | grep none | awk '{print $3}' | sponge | xargs docker rmi";

        # k8s
        k = "kubectl";
        kx = "kubectx";
        ka = "kubectl get pods";
        kaw = "kubectl get pods -o wide";
        knuke = "kubectl delete pods --grace-period=0 --force";
        klist =
          "kubectl get pods --all-namespaces -o jsonpath='{..image}' | tr -s '[[:space:]]' '\\n' | sort | uniq -c";
        kshell = ''
          kubectl run "jacobi-''${RANDOM}" -it --image-pull-policy=Always --rm --restart Never --image=alpine:latest'';

        # aws stuff
        aws_id = "aws sts get-caller-identity --query Account --output text";

        # misc
        rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
        space = "du -Sh | sort -rh | head -10";
        now = "date +%s";
      };
      initExtra = ''
        HISTCONTROL=ignoreboth
        set +h
        export PATH="$PATH:$HOME/.bin/"
        export PATH="$PATH:$HOME/.npm/bin/"

        # asdf and base nix
      # '' + (
      #   if isDarwin then ''
      #     [[ -e /usr/local/opt/asdf/asdf.sh ]] && source /usr/local/opt/asdf/asdf.sh
      #     [[ -e /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash ]] && source /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash
      #   '' else ''
      #     [[ -e $HOME/.asdf/asdf.sh ]] && source $HOME/.asdf/asdf.sh
      #     [[ -e $HOME/.asdf/completions/asdf.bash ]] && source $HOME/.asdf/completions/asdf.bash
      #   ''
      # ) + ''
        [[ -e ~/.nix-profile/etc/profile.d/nix.sh ]] && source ~/.nix-profile/etc/profile.d/nix.sh

        _kube_contexts() {
          local curr_arg;
          curr_arg=''${COMP_WORDS[COMP_CWORD]}
          COMPREPLY=( $(compgen -W "- $(kubectl config get-contexts --output='name')" -- $curr_arg ) );
        }

        _kube_namespaces() {
          local curr_arg;
          curr_arg=''${COMP_WORDS[COMP_CWORD]}
          COMPREPLY=( $(compgen -W "- $(kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')" -- $curr_arg ) );
        }

        # additional aliases
        [[ -e ~/.aliases ]] && source ~/.aliases

        # bash completions
        export XDG_DATA_DIRS="$HOME/.nix-profile/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
        source <(kubectl completion zsh)
        source <(just --completions zsh)
      '';
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.mcfly = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = false;
      defaultCommand = "fd -tf -c always -H --ignore-file ${./ignore} -E .git";
      defaultOptions = words "--ansi --reverse --multi --filepath-word";
    };

    home.file = {
      prettierrc = {
        target = ".prettierrc.js";
        text = ''
          const config = {
            printWidth: 100,
            arrowParens: 'always',
            singleQuote: true,
            tabWidth: 2,
            useTabs: false,
            semi: true,
            bracketSpacing: false,
            jsxBracketSameLine: false,
            requirePragma: false,
            proseWrap: 'preserve',
            trailingComma: 'all',
          };
          module.exports = config;
        '';
      };
      npmrc = {
        target = ".npmrc";
        text = ''
          prefix=~/.npm
        '';
      };
      ${attrIf isLinux "gpgconf"} = {
        target = ".gnupg/gpg.conf";
        text = ''
          use-agent
          pinentry-mode loopback
        '';
      };
      ${attrIf isLinux "gpgagentconf"} = {
        target = ".gnupg/gpg-agent.conf";
        text = ''
          allow-loopback-pinentry
        '';
      };
    };

    # starship config
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[${promptChar}](bright-green)";
          error_symbol = "[${promptChar}](bright-red)";
        };
        golang = {
          style = "fg:#00ADD8";
          symbol = "go ";
        };
        directory.style = "fg:#d442f5";
        nix_shell = {
          pure_msg = "";
          impure_msg = "";
          format = "via [$symbol$state]($style) ";
        };
        kubernetes = {
          disabled = false;
          style = "fg:#326ce5";
        };
        terraform = {
          disabled = false;
          format = "via [$symbol $version]($style) ";
          symbol = "🌴";
        };
        nodejs = { symbol = "⬡ "; };

        # disabled plugins
        aws.disabled = true;
        cmd_duration.disabled = true;
        gcloud.disabled = true;
        package.disabled = true;
      };
    };

    # gitconfig
    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = name;
      userEmail = if isDarwin then personalEmail else workEmail;
      aliases = {
        A = "add -A";
        pu = "pull";
        pur = "pull --rebase";
        cam = "commit -am";
        ca = "commit -a";
        cm = "commit -m";
        ci = "commit";
        co = "checkout";
        st = "status";
        br = "branch -v";
        hide = "update-index --skip-worktree";
        unhide = "update-index --no-skip-worktree";
        hidden = "! git ls-files -v | grep '^S' | cut -c3-";
        branch-name = "!git rev-parse --abbrev-ref HEAD";
        # Delete the remote version of the current branch
        unpublish = "!git push origin :$(git branch-name)";
        # Push current branch
        put = "!git push origin $(git branch-name)";
        # Pull without merging
        get = "!git pull origin $(git branch-name) --ff-only";
        # Pull Master without switching branches
        got =
          "!f() { CURRENT_BRANCH=$(git branch-name) && git checkout $1 && git pull origin $1 --ff-only && git checkout $CURRENT_BRANCH;  }; f";
        # Recreate your local branch based on the remote branch
        recreate = ''
          !f() { [[ -n $@ ]] && git checkout master && git branch -D "$@" && git pull origin "$@":"$@" && git checkout "$@"; }; f'';
        reset-submodule = "!git submodule update --init";
        sl = "!git --no-pager log -n 15 --oneline --decorate";
        sla = "log --oneline --decorate --graph --all";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        shake = "remote prune origin";
      };
      extraConfig = {
        color.ui = true;
        push.default = "simple";
        pull.ff = "only";
        checkout.defaultRemote = "origin";
        core = {
          editor = if isDarwin then "code --wait" else "nano";
          pager = "delta --dark";
        };
        rebase.instructionFormat = "<%ae >%s";
      };
    };
    # programs.git.signing = {
    #   key = "03C0CBEA6EAB9258";
    #   gpgPath = "gpg";
    #   signByDefault = true;
    # };

    programs.tmux = {
      enable = true;
      tmuxp.enable = true;
      historyLimit = 500000;
      extraConfig = ''
        set -g base-index 1
        set -g pane-base-index 1
        # Setting the prefix from `C-b` to `C-a`.
        # By remapping the `CapsLock` key to `Ctrl`,
        # you can make triggering commands more comfottable!
        set -g prefix C-a

        set -g status-keys vi
        setw -g mode-keys vi
        setw -g mouse on
        setw -g monitor-activity on

        # Moving between windows.
        unbind [
        unbind ]
        bind -r [ select-window -t :-
        bind -r ] select-window -t :+

        # Pane resizing.
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        # Maximize and restore a pane.
        unbind Up
        bind Up new-window -d -n tmp \; swap-pane -s tmp.1 \; select-window -t tmp
        unbind Down
        bind Down last-window \; swap-pane -s tmp.1 \; kill-window -t tmp

        # Log output to a text file on demand.
        bind P pipe-pane -o "cat >>~/#W.log" \; display "Toggled logging to ~/#W.log"


        # -- display -------------------------------------------------------------------
        # tabs
        set -g window-status-current-format "#[fg=black]#[bg=red] #I #[bg=brightblack]#[fg=brightwhite] #W#[fg=brightblack]#[bg=black]"
        set -g window-status-format "#[fg=black]#[bg=yellow] #I #[bg=brightblack]#[fg=brightwhite] #W#[fg=brightblack]#[bg=black]"

        # status bar
        set-option -g status-position bottom
        set-option -g status-justify left
        set -g status-fg colour1
        set -g status-bg colour0
        set -g status-left ' '
        set -g status-right '#(date +"%_I:%M")'
        set-option -g set-titles on
        #256 colors
        set -g default-terminal "xterm-256color"
        set -ga terminal-overrides ",xterm-256color:Tc"
        #Don't auto remane windows
        set-option -g allow-rename off
        # Source config
        unbind r
        bind r source-file ~/.tmux.conf \; display "Finished sourcing ~/.tmux.conf ."


        # Use Alt-arrow keys without prefix key to switch panes
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window


        # allow fn+left/right
        bind-key -n Home send Escape "OH"
        bind-key -n End send Escape "OF"

        setw -g monitor-activity off
        setw -g monitor-activity on
        set-option -g bell-action none
      '';
    };
  }
