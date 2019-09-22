rec {
    firrtl = import ./firrtl.nix;
    chisel3 = import ./chisel3.nix { inherit firrtl; };
}
