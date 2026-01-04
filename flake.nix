{
  description = "Neovim nightly prebuilt binaries";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      mkNeovim =
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          # nightly tag (always latest)
          version = "nightly";

          asset =
            if system == "x86_64-linux" then
              "nvim-linux-x86_64.tar.gz"
            else if system == "aarch64-linux" then
              "nvim-linux-arm64.tar.gz"
            else if system == "x86_64-darwin" then
              "nvim-macos-x86_64.tar.gz"
            else if system == "aarch64-darwin" then
              "nvim-macos-arm64.tar.gz"
            else
              throw "Unsupported system: ${system}";

          url = "https://github.com/neovim/neovim/releases/download/${version}/${asset}";
        in
        pkgs.stdenv.mkDerivation {
          pname = "neovim";
          inherit version;

          src = pkgs.fetchurl {
            inherit url;

            # Use a fake hash once, then replace it
            sha256 = "sha256-ZkZBPfFptq2Y+oEVFxo1x7mi4X6jc6UZ7VyMJdy51Rw=";
          };

          installPhase = ''
            mkdir -p $out
            tar xzf $src --strip-components=1 -C $out
          '';

          meta = {
            description = "Neovim nightly prebuilt binary";
            homepage = "https://neovim.io";
            license = pkgs.lib.licenses.asl20;
            platforms = pkgs.lib.platforms.unix;
          };
        };
    in
    {
      packages = {
        x86_64-linux.neovim = mkNeovim "x86_64-linux";
        aarch64-linux.neovim = mkNeovim "aarch64-linux";
        x86_64-darwin.neovim = mkNeovim "x86_64-darwin";
        aarch64-darwin.neovim = mkNeovim "aarch64-darwin";
      };

      defaultPackage = {
        x86_64-linux = self.packages.x86_64-linux.neovim;
        aarch64-linux = self.packages.aarch64-linux.neovim;
        x86_64-darwin = self.packages.x86_64-darwin.neovim;
        aarch64-darwin = self.packages.aarch64-darwin.neovim;
      };

      apps.x86_64-linux.neovim = {
        type = "app";
        program = "${self.packages.x86_64-linux.neovim}/bin/nvim";
      };
    };
}
