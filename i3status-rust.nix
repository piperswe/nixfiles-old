{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "cbbfc141a97b04a20eb4ec0fd83e93b5b3843976";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = version;
    sha256 = "0qj5y2ylfma9x58jc40kxngyah5bafkqnhl2zpy96xaxy0bkizga";
  };

  cargoSha256 = "0nf3bwg4kcdb82g2w3dgfp6q81gk4kndvcm1mcly45smf6wapxaf";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Very resource-friendly and feature-rich replacement for i3status";
    homepage = "https://github.com/greshake/i3status-rust";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
