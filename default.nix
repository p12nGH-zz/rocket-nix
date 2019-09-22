rec {
    firrtl = import ./firrtl.nix;
    chisel3-coreMacros = import ./chisel3.nix { inherit firrtl; };
}
