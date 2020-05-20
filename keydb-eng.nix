{ stdenv, unzip, fetchzip, ... }:

stdenv.mkDerivation {
  name = "keydb-eng";
  inherit unzip;
  src = fetchzip {
    url = "http://fvonline-db.bplaced.net/export/keydb_eng.zip";
    sha256 = "00l6bz65r4j93hw852z4fbqgihbi25wa1nfwjy0ili0v097360fj";
  };
  installPhase = ''
    cp $src/keydb.cfg $out
  '';
}
