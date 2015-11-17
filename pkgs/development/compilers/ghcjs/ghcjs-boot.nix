{ fetchgit }:
fetchgit {
  url = git://github.com/ghcjs/ghcjs-boot.git;
  rev = "cad49063e74bb0a38428fd587677a0adf1d01701";
  sha256 = "0fmq70nh4ak3riby8f8gik5flvrkh28r2f6k4s2wb5gaw0a8bqa8";
  fetchSubmodules = true;
}
