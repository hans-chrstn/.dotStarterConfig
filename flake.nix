{
  description = "Flake by Mishima";

  nixConfig = {
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    substituers = [
      "https://cache.garnix.io"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default-linux";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";

    zen-browser.url = "github:MarceColl/zen-browser-flake";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-snapd = {
      url = "github:io12/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix-darwin.url = "github:Believer1/spicetify-nix";

    ags.url = "github:Aylur/ags";

    ags-v2.url = "github:Aylur/ags/v2";

    nur.url = "github:nix-community/NUR";

    prismlauncher = {
      url = "github:julcioo/PrismLauncher-Cracked";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
 
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs = {
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };   

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs = {
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs = {
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hyprland";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib // nix-darwin.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );

  in {
    inherit lib;
    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    formatter = forEachSystem (pkgs: pkgs.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    darwinConfigurations = {
      # HACKINTOSH
      "nix-darwin" = lib.darwinSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [ ./hosts/nix-darwin/default.nix ];
      };
    };

    nixosConfigurations = {
      # PERSONAL LAPTOP
      hayato = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [ ./hosts/hayato/default.nix ];
      };

      # MAIN DESKTOP
      mishima = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [ ./hosts/mishima/default.nix ];
      };

      # WSL
      toru = lib.nixosSystem {
      	specialArgs = { inherit inputs outputs; };
	      system = "x86_64-linux";
	      modules = [ ./hosts/toru/default.nix self.nixosModules.virtualise ];
      };
    };

    homeConfigurations = {
      # PERSONAL LAPTOP
      hayato = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [ ./home/hayato/default.nix ];
      };

      # MAIN DESKTOP
      mishima = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [ ./home/mishima/default.nix ];
      };

      # WSL
      toru = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [ ./home/toru/default.nix ];
      };

      # HACKINTOSH
      "nix-darwin" = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-darwin;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [ ./home/nix-darwin/default.nix ];
      };
    };
  };
}
