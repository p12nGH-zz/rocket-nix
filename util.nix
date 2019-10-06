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
      [ (import ./dependencies.nix)."${d}".jar ]
    else
      d.jars;

  jarLookupDeps = deps: lib.unique (builtins.concatMap jarLookup deps);

  mkCP = deps:
    builtins.concatStringsSep ":" (jarLookupDeps deps);

  scalaProject =
    { name
    , src
    , deps
    , scalac_options ? "" }: fix (self: stdenv.mkDerivation {

    inherit name src scalac_options;
    buildInputs = [ scala_2_12 ];
    CLASSPATH = mkCP deps;
    _JAVA_OPTIONS = "-Xms1024m -Xmx2G -Xss256m";
    paradise = jarLookup "paradise_2.12.9";


    buildInfo = let
      nameNoDashes = builtins.replaceStrings ["-"] [""] name;
    in
      builtins.toFile "BuildInfo.scala" ''
        package ${nameNoDashes}

        case object BuildInfo {        val version: String = "todo"
          override val toString: String = "BuildInfo toString not implemented"
        }
      '';

    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      set -xe

      mkdir -p $out/share/java
      : Classpath: $CLASSPATH
      scalac \
        -deprecation -Yrangepos -unchecked -language:implicitConversions $scalac_options \
        -Xplugin:$paradise \
        $buildInfo $(find $src -name '*.scala') \
        -d $out/share/java/$name.jar
      set +x
    '';
    passthru.jars = (jarLookupDeps deps) ++ [ "${self}/share/java/${name}.jar" "${scala_2_12}/lib/scala-library.jar" ];
  });
}
