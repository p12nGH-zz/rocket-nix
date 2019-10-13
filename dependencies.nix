{ fetchMavenArtifact, fetchFromGitHub }:

let
  fix = f: let x = f x; in x;
  fetch = mapName: l: {
    name = mapName (builtins.elemAt l 0);
    value = fix (this: fetchMavenArtifact {
      artifactId = builtins.elemAt l 0;
      groupId = builtins.elemAt l 1;
      version = builtins.elemAt l 2;
      sha256 = builtins.elemAt l 3;
    } // { jars = [ this.jar ]; });
  };

  javaDep = fetch (n: n);
  # like java dep, but remove Scala version from name
  scalaDep = fetch (n: with builtins; head (split "_2." n));
  depsList = fetch: ds: builtins.listToAttrs (map fetch ds);

  depsListGitHub =
    let
      op = tree: repoParams:
        let
          owner = builtins.elemAt repoParams 0;
          repo = builtins.elemAt repoParams 1;
          fetched = {
            "${repo}" = fetchFromGitHub {
              inherit owner repo;
              rev = builtins.elemAt repoParams 2;
              sha256 = builtins.elemAt repoParams 3;
            };
          };
        in
          tree // { "${owner}" = (tree."${owner}" or {}) // fetched; };
    in
      builtins.foldl' op {};

in {
  java = depsList javaDep [
    # misc Java dependencies
    [ "logback-classic"      "ch.qos.logback"              "1.2.3"        "1q1pmkmsadlaknsj1c7b1741vv2n408kiqan784qzjvzkr9zhlzv" ]
    [ "junit"                "junit"                       "4.12"         "0shibkq1faqc7j8cl0n5swscazanzzcqfy37j15xh8z20l41ywjr" ]
    [ "commons-text"         "org.apache.commons"          "1.6"          "02x702m3yzy1wyc09xms13q8p3qmri1rsg4m2vkhygmn95jyaifz" ]
    [ "antlr4"               "org.antlr"                   "4.7.1"        "11qd1ak24wdra5pbdczdjla5msw0s1adqs15hcl3g2gbz3rc5kd2" ]
    [ "antlr4-runtime"       "org.antlr"                   "4.7.1"        "07f91mjclacrvkl8a307w2abq5wcqp0gcsnh0jg90ddfpqcnsla3" ]
    [ "antlr-complete"       "org.antlr"                   "3.5.2"        "0srjwxipwsfzmpi0v32d1l5lzk9gi5in8ayg33sq8wyp8ygnbji6" ]
    [ "protobuf-java"        "com.google.protobuf"         "3.8.0"        "03z6kgkmg0hqw7cplh8wbd5mbhknwqwqzamg97mhgbfxd6l91fll" ]
    [ "joda-time"            "joda-time"                   "2.10.3"       "12cfaw67vsg57d8wc7nvb5phzwh4k7zrharzmbjs5yrnvsmaddpb" ]
    [ "jackson-databind"     "com.fasterxml.jackson.core"  "2.9.10"       "0mqp4ikn230gf8mii9kfm65kl7gl8mr1v85182fgbkfd7ykp3fs9" ]
    [ "jackson-core"         "com.fasterxml.jackson.core"  "2.9.10"       "0lrc4br6zxk1ik3v723d68s2ki2bx7r3ivl65ijhji2aapbjdzk5" ]
    [ "jackson-annotations"  "com.fasterxml.jackson.core"  "2.9.10"       "0k4rxrmc5hl91bqmpizgcxrnjxbqinfwq76irls8l40gbplg4xn8" ]
    [ "paranamer"            "com.thoughtworks.paranamer"  "2.8"          "01yzrqxcdv2vc6xj8ymlwj5nhcb0jn620mg8728q2782lqcb3338" ]
    [ "commons-lang3"        "org.apache.commons"          "3.9"          "0c62qd6s9gh8krzsscwfy92aka96cyh631l5rsl1gy9yrz6isbny" ]
  ];

  scala = depsList scalaDep [
    # Scala 2.12.9
    [ "scala-logging_2.12"   "com.typesafe.scala-logging"  "3.9.0"        "1g08fhvycn2vfqvxsgq27s8rfy24v1a1fl0v5jhrjsz2j6c3q1sq" ]
    [ "scalatest_2.12"       "org.scalatest"               "3.0.5"        "1r85w0m5m9rs52yf25nkslf2vz2pwhk5g2ldk93dl837xyyba5ml" ]
    [ "scalacheck_2.12"      "org.scalacheck"              "1.14.0"       "0bp6xkzbllrcblyw3yg781gdkdrjcs0lfl0rfjz06jxp5clmnvqy" ]
    [ "scopt_2.12"           "com.github.scopt"            "3.7.0"        "0micrr3iwq6bcxqxdra9gj0njypxm4qk5144k9my0rzj34lgy18i" ]
    [ "moultingyaml_2.12"    "net.jcazevedo"               "0.4.0"        "1zg9z799pd9hs32x3f2190h58ldpdy6mj9xyma02wia6vb38x4b9" ]
    [ "json4s-native_2.12"   "org.json4s"                  "3.6.1"        "0zkkg4b1n3bv8i7w5alv0h1dfarcmdk94lrvlw37sq90p3d6niva" ]
    [ "json4s-jackson_2.12"  "org.json4s"                  "3.6.1"        "0hw0r0ar3wq4fc8x2kpd4b42s9938rkdmlvx7nnj5w39ksim9f43" ]
    [ "json4s-ext_2.12"      "org.json4s"                  "3.6.1"        "0hz4igzissb1kspajjvrri1fswqa25gmlbn7zvsdfr2c11acqa84" ]
    [ "json4s-core_2.12"     "org.json4s"                  "3.6.1"        "1h6szj8v5np6fkn8424djy6mxndsczsn9fihbcllx8i9ji883x70" ]
    [ "json4s-ast_2.12"      "org.json4s"                  "3.6.1"        "0ikpdxwqss0jva60iil3mxcjxgsvqr76hgaf1kmk53pj3mhdxirr" ]
    [ "json4s-scalap_2.12"   "org.json4s"                  "3.6.1"        "1iffd92gdchgnyjwbszymh9jqvmkd6dbbx7f8jf71ivngiwzcd0c" ]
    [ "nscala-time_2.12"     "com.github.nscala-time"      "2.16.0"       "13cjvv4yn9yg3n4zjinv43r4jynk8b7zvyipvs55sk19w3dngvmc" ]
    [ "paradise_2.12.9"      "org.scalamacros"             "2.1.0"        "18ps28pg24cmggkmxzzxd65z3zwrzhnp52kdd4p1an2iacfqvkf5" ]
    [ "scala-reflect"        "org.scala-lang"              "2.12.8"       "0niiazlnflwz7j9f5ap9bl9l4gly6f1a12x0rq2cx6a5bhwhar2d" ]
    [ "scalactic_2.12"       "org.scalactic"               "3.2.0-M1"     "0443ngps1ffibdww8r6y1m2dif5051lrirsivvnb855vbi72wyvm" ]
  ];

  fromGitHub = depsListGitHub [
    [ "freechipsproject" "firrtl"             "5e9b286185e98c58e5fde1987c48d085ebdb1e25" "0y0lqa4r7401zkzymigcw2g8adyvkr02nxsgc8pbnz6r2z8kx0q3" ]
    [ "freechipsproject" "chisel3"            "e1aa5f3f5c0cdeb204047c3ca50801d9f7ea25f1" "1349q70hcy14cqpl8ff9v052na3qsyzaaf7180vh771jzd057gq4" ]
    [ "ucb-bar"          "berkeley-hardfloat" "3ca9cc7901b91ddccf3fcfd686aa7a93ed48d84f" "0ybyxcqiyrcg2jhacjq83zpmghxsn3x9rpb0wdigcz9xk1mvpisg" ]
    [ "chipsalliance" "api-config-chipsalliance" "d619ca850846d2ec36da64bf8a28e7d9a3d9ed1b" "0cr0v2i8619c1mzq27yf7bg19dzkb50h1x2c0crr04m83wjapny5"]
    [ "chipsalliance"    "rocket-chip"        "d42b521df4596bd6425b675794a06da08991eea0" "0yaq76zw07pjxsrf4pjy98jlixy8zdjw2k69jn4sk9y0lca0rv2s" ]
  ];
}
