{ pkgs, stdenv, fetchurl, unzip, makeWrapper, atomEnv, vivaldi-ffmpeg-codecs, at-spi2-core }:
stdenv.mkDerivation rec {
  pname = "github-classroom-assistant";
  version = "2.0.1";
  src = fetchurl {
    url = "https://github.com/education/classroom-assistant/releases/download/v${version}/Classroom.Assistant-linux-x64-${version}.zip";
    sha256 = "1hskrnqivgh7vzxa1z9ab7pw4vn822mrbz8dqsr0czmlinvdv4p8";
  };
  nativeBuildInputs = [
    unzip
    makeWrapper
  ];
  buildInputs = [
    unzip
    vivaldi-ffmpeg-codecs
    at-spi2-core
  ];
  rpath = with pkgs; lib.concatStringsSep ":" [
    atomEnv.libPath
    (lib.makeLibraryPath [ vivaldi-ffmpeg-codecs at-spi2-core ])
    (lib.makeSearchPathOutput "lib" "lib64" [ vivaldi-ffmpeg-codecs at-spi2-core ])
  ];
  dynamic-linker = pkgs.stdenv.cc.bintools.dynamicLinker;
  fixupPhase = ''
    patchelf \
      --set-interpreter "$dynamic-linker" \
      --set-rpath "$rpath" \
      $out/share/classroom-assistant/classroom-assistant
  '';
  installPhase = ''
    mkdir -p $out/{share,bin}
    cp -R . $out/share/classroom-assistant
    makeWrapper $out/share/classroom-assistant/classroom-assistant $out/bin/classroom-assistant
  '';
}
