{
  description = "Home nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";   
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ 
    self, 
    nix-darwin, 
    nixpkgs, 
    mac-app-util,
    nix-homebrew, 
   }:
  let
    configuration = { pkgs, ... }: {   

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.neovim
        ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "eza"
          "fzf"
          "zsh-syntax-highlighting"
          "pass"
          "uv"
          "imagemagick"
        ];

        casks = [
          "makemkv"
          "localsend"
          "openlp"
          "iterm2"
          "firefox"
          "brave-browser"
          "notion"
          "microsoft-word"
          "microsoft-excel"
          "microsoft-outlook"
          "adobe-creative-cloud"
          "affinity-publisher"
          "affinity-photo"
          "raycast"
          "bitwarden"
          "moonlight"
          "nikitabobko/tap/aerospace"
          "onedrive"
          "tailscale"
          "spotify"
          "hammerspoon"
          "calibre"
        ];
        
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      system.defaults = {
        dock.autohide = true;
        dock.orientation = "left";
        dock.mru-spaces = false;
        dock.autohide-time-modifier = 0.0;
        dock.autohide-delay = 0.0;
        dock.persistent-apps = [
        "/Applications/Brave Browser.app"
        "/System/Applications/Mail.app"
        "/Applications/Microsoft Outlook.app"
        "/Applications/Moonlight.app/"
        "/Applications/iTerm.app/"
        "/System/Applications/Calendar.app"
        ];
        finder.FXPreferredViewStyle = "clmv";
        finder.AppleShowAllExtensions = true;
        finder.FXRemoveOldTrashItems = true;
        finder.NewWindowTarget = "Home";
        finder.ShowPathbar = true;
        loginwindow.GuestEnabled = false;
        loginwindow.LoginwindowText = "Fred være med dere";
        screencapture.location = "~/Pictures/skjermbilder";
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
      };

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";
      #nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Hombrew under default prefix
            enable = true;

            # User owning Homebrew prefix
            user = "fredrikarnstad";

          };
        }
      ];
    };
  };
}
