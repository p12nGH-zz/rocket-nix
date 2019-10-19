rec {
  nixpkgs = import <nixpkgs> {};
  util = import ./util.nix {
    inherit dependencies nixpkgs;
  };
  dependencies = import ./dependencies.nix {
    inherit (nixpkgs) fetchMavenArtifact fetchFromGitHub;
  };
  firrtl = import ./firrtl.nix {
    inherit dependencies util nixpkgs;
  };
  chisel3 = import ./chisel3.nix {
    inherit dependencies firrtl;
    inherit (util) scalaProject;
  };
  hardfloat = import ./hardfloat.nix {
    inherit chisel3 dependencies;
    inherit (util) scalaProject;
  };
  rocketchip = import ./rocketchip.nix {
    inherit chisel3 hardfloat dependencies util nixpkgs;
  };
  generate = import ./generate.nix {
    inherit rocketchip firrtl nixpkgs dependencies;
  };
  toolchain = import ./toolchain.nix {
    inherit nixpkgs;
  };
}
