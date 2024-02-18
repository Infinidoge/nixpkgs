{ stdenv, lib }:

let
  variant = if stdenv.hostPlatform.isMusl then "alpine_linux" else "linux";
  sources = lib.importJSON ./sources.json;
  source = sources.openjdk16.${variant};

  mkJava = type: var: {
    "${type}-${var}" = if (source ? ${type} && source ? ${var})
      then (import ./jdk-linux-base.nix {
        sourcePerArch = source.${type}.${var};
        knownVulnerabilities = [ "Support ended" ];
      })
      else throw "adoptopenjdk does not support this version/architecture";
  };
in
(mkJava "jdk" "hotspot") // (mkJava "jre" "hotspot") // (mkJava "jdk" "openj9") // (mkJava "jre" "openj9")
