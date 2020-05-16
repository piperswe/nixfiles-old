{ stdenv, unzip, fetchzip, ... }:

stdenv.mkDerivation {
  name = "keydb-eng";
  inherit unzip;
  src = fetchzip {
    url = "http://fvonline-db.bplaced.net/export/keydb_eng.zip";
    sha256 = "1d1vdza1wl16zh7b6lydr6zhkk40f6jbgnkf8pcp0pnhg6rbm6dn";
  };
  installPhase = ''
    cp $src/keydb.cfg $out
  '';
}
