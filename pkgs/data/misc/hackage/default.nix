{ fetchFromGitHub
, stdenv
, pkgconfig
, libarchive
, glib
, # Override this to use a different revision
  src-spec ?
    { owner = "commercialhaskell";
      repo = "all-cabal-hashes";
      rev = "60443435510c1523ae4596f20595a274531dd485";
      sha256 = "1k3c0ix5rax92ywrpjxd7cmbzwsgrv03s6dvq6wjm8vljchqg4li";
    }
, lib
}:

# Use builtins.fetchTarball "https://github.com/commercialhaskell/all-cabal-hashes/archive/hackage.tar.gz"
# instead if you want the latest Hackage automatically at the price of frequent re-downloads.
let partition-all-cabal-hashes = stdenv.mkDerivation
      { name = "partition-all-cabal-hashes";
        src = ./partition-all-cabal-hashes.c;
        unpackPhase = "true";
        buildInputs = [ libarchive glib ];
        nativeBuildInputs = [ pkgconfig ];
        buildPhase =
          "cc -O3 $(pkg-config --cflags --libs libarchive glib-2.0) $src -o partition-all-cabal-hashes";
        installPhase =
          ''
            mkdir -p $out/bin
            install -m755 partition-all-cabal-hashes $out/bin
          '';
      };
in fetchFromGitHub (src-spec //
  { postFetch = "${partition-all-cabal-hashes}/bin/partition-all-cabal-hashes $downloadedFile $out";
  })
