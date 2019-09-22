with import <nixpkgs> {};

rec {
  mavenDep = l: {
    name = builtins.elemAt l 0;
    value = fetchMavenArtifact {
      artifactId = builtins.elemAt l 0;
      groupId = builtins.elemAt l 1;
      version = builtins.elemAt l 2;
      sha256 = builtins.elemAt l 3;
    };
  };

  fix = f: let x = f x; in x; 

  jarLookup = d:
    if (builtins.isString d) then
      (import ./dependencies.nix)."${d}".jar
    else
      d.jar;

  mkCP = deps:
    builtins.concatStringsSep ":" (map jarLookup deps);
}
