{rocketchip, firrtl, nixpkgs, dependencies}:

rec {
  fir = conf: nixpkgs.stdenv.mkDerivation {
    name = "${conf}.firrtl";
    buildInputs = [ rocketchip nixpkgs.dtc nixpkgs.xz ];
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
    src = dependencies.fromGitHub.chipsalliance.rocket-chip;
  };

  verilog = conf: nixpkgs.stdenv.mkDerivation {
    name = "${conf}.verilog";
    buildInputs = [ firrtl nixpkgs.xz ];

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
}
