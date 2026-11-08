{
  description = "A tiny app to test build.bresilla.com on three architectures";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { nixpkgs, ... }:
    let
      # Go builds for any architecture from any machine, so no toolchain is compiled.
      hello = system: goarch:
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.stdenvNoCC.mkDerivation {
          pname = "hello-${goarch}";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.go ];
          buildPhase = ''
            export HOME=$TMPDIR GOCACHE=$TMPDIR/go CGO_ENABLED=0 GOOS=linux GOARCH=${goarch}
            go build -o hello .
          '';
          installPhase = "install -Dm755 hello $out/bin/hello";
        };
      builds = {
        # Built on tron, the x86_64 builder; riscv64 is cross-built there.
        x86_64-linux = {
          hello = hello "x86_64-linux" "amd64";
          hello-riscv64 = hello "x86_64-linux" "riscv64";
        };
        # Built on lama, the aarch64 builder.
        aarch64-linux.hello = hello "aarch64-linux" "arm64";
      };
    in
    {
      packages = builds;
      checks = builds;
    };
}
