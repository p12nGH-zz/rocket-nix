{ nixpkgs }:

with nixpkgs;

stdenv.mkDerivation {
  name = "riscv-toolchain";
  src = fetchurl {
    url = https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz;
    sha256 = "03vyx11p110crck1g2fgrp8mv6b87i56avi5nw19045nmpv1p1cj";
  };
  buildInputs = [file];
  installPhase = ''
    mkdir $out
    set -x
    for f in $(file $(find riscv64-unknown-elf/bin/ bin/ libexec/gcc/riscv64-unknown-elf/* -type f) | grep 'ELF 64-bit LSB executable' | sed -e 's/:.*$//'); do
      patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 $f
      patchelf --set-rpath ${stdenv.glibc}/lib $f
    done
    set +x
    cp -r * $out
  '';
  fixupPhase = " "; # default fixup phase breaks binaries
}
