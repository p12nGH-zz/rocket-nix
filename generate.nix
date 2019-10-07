{rocketchip, firrtl}:

with import <nixpkgs> {};

let
  fir = conf: stdenv.mkDerivation {
    name = "${conf}.firrtl";
    buildInputs = [ rocketchip.rocketchip dtc xz ];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir $out
      cp -r $src/bootrom .
      rocketchip  $out \
        freechips.rocketchip.system \
        TestHarness \
        freechips.rocketchip.system \
        $conf
      cd $out
      xz *
    '';
    inherit conf;

    # needed for bootrom.img
    src = rocketchip.rocketchip-src;
  };

  verilog = conf: stdenv.mkDerivation {
    name = "${conf}.verilog";
    buildInputs = [ firrtl xz ];

    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir $out
      cp $firrtl/*.fir.xz .
      unxz *fir.xz
      firrtl -i *.fir -o $out/generated.v
      xz $out/generated.v
    '';
    firrtl = fir conf;
  };
in
{
  inherit fir verilog;
}
