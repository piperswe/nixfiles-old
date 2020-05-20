with import ./nixpkgs.nix;

rustPlatform.buildRustPackage rec {
  pname = "zenith";
  version = "bf8bb61460e6dc8089a05a4eefca78d684189d6d";

  src = fetchFromGitHub {
    owner = "bvaisvil";
    repo = pname;
    rev = version;
    sha256 = "0s20vjm8irlbw8z611qwfxwr6m1zqq9l3zr2dh65dl95b6v1k3fd";
  };

  cargoSha256 = "1jgr4i3bdgjhfy6af1m34qh6fkzf64prldf2d4vc1rii037zvx7s";

  meta = with stdenv.lib; {
    description = "Sort of like top or htop but with zoom-able charts, network, and disk usage";
    homepage = "https://github.com/bvaisvil/zenith";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
