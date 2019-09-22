with import <nixpkgs> {};
{
  mavenDepX = l: {
    name = builtins.elemAt l 0;
    value = fetchMavenArtifact {
      artifactId = builtins.elemAt l 0;
      groupId = builtins.elemAt l 1;
      version = builtins.elemAt l 2;
      sha256 = builtins.elemAt l 3;
    };
  };

  fix = f: let x = f x; in x; 

  mkCP = deps:
    builtins.concatStringsSep
      ":"
      (map (d: (import ./dependencies.nix)."${d}".jar) deps);
}
