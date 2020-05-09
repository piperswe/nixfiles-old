{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "1b1f6680ff3d4da0a14c1e4329b6403816f2a8f4";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "${version}";
    sha256 = "0hnm75hm0k6cpgjqrri2x22h336g9c4s2p4ba5vnhhsd1xa0rvsk";
  };

  cargoSha256 = "0jdwcyw4bx7fcrscfarlvlbp2jaajmjabkw2a3w3ld07dchq0wb0";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Very resource-friendly and feature-rich replacement for i3status";
    homepage = "https://github.com/greshake/i3status-rust";
    license = licenses.gpl3;
    maintainers = with maintainers; [ backuitist globin ma27 ];
    platforms = platforms.linux;
  };
}
