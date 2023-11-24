{
  description = "zkSync development shell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  inputs.fenix.url = "github:nix-community/fenix";
  outputs = {
    self,
    nixpkgs,
    fenix,
  }: {
    packages.x86_64-linux.default = with import nixpkgs {system = "x86_64-linux";};
      pkgs.mkShell {
        name = "zkSync";
        src = ./.;
        buildInputs = [
          docker-compose
          nodejs
          yarn
          axel
          libclang
          openssl
          pkg-config
          postgresql
          python3
          solc
          (with fenix.packages.${system};
            combine [
              default.toolchain
              targets.x86_64-unknown-linux-musl.latest.rust-std
            ])
        ];

        # for RocksDB and other Rust bindgen libraries
        LIBCLANG_PATH = lib.makeLibraryPath [libclang.lib];
        BINDGEN_EXTRA_CLANG_ARGS = ''-I"${libclang.lib}/lib/clang/16/include"'';

        shellHook = ''
          export ZKSYNC_HOME=$PWD
          export PATH=$ZKSYNC_HOME/bin:$PATH
        '';

        # hardhat solc requires ld-linux
        # Nixos has to fake it with nix-ld
        NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [];
        NIX_LD = builtins.readFile "${stdenv.cc}/nix-support/dynamic-linker";
      };
  };
}
