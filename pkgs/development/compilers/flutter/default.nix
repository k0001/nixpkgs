{ callPackage }:

let
  mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in map (f: dir + ("/" + f)) files;
in {
  stable = mkFlutter rec {
    pname = "flutter";
    channel = "stable";
    version = "1.17.5";
    filename = "flutter_linux_${version}-${channel}.tar.xz";
    sha256Hash = "0kapja3nh7dfhjbn2np02wghijrjnpzsv4hz10fj54hs8hdx19di";
    patches = getPatches ./patches/stable;
  };
  beta = mkFlutter rec {
    pname = "flutter-beta";
    channel = "beta";
    version = "1.20.0-7.2.pre";
    filename = "flutter_linux_${version}-${channel}.tar.xz";
    sha256Hash = "0w89ig5vi4spa95mf08r4vvwni7bzzdlyhvr9sy1a35qmf7j9s6f";
    patches = getPatches ./patches/beta;
  };
  dev = mkFlutter rec {
    pname = "flutter-dev";
    channel = "dev";
    version = "1.17.0-dev.5.0";
    filename = "flutter_linux_${version}-${channel}.tar.xz";
    sha256Hash = "0ks2jf2bd42y2jsc91p33r57q7j3m94d8ihkmlxzwi53x1mwp0pk";
    patches = getPatches ./patches/beta;
  };
}
