rec {
  firrtl = import ./firrtl.nix;
  chisel3 = import ./chisel3.nix { inherit firrtl; };
  hardfloat = import ./hardfloat.nix { inherit chisel3; };
  rocket = import ./rocket.nix { inherit chisel3 hardfloat; };
}
