{ stdenv, unzip, fetchzip, ... }:

stdenv.mkDerivation {
  name = "keydb-eng";
  inherit unzip;
  src = fetchzip {
    url = "http://fvonline-db.bplaced.net/export/keydb_eng.zip";
    sha256 = "19nismch2dzd6vc3a3qcjqpzf1cyr8mwlvazd61n664hs86glax7";
  };
  installPhase = ''
    cp $src/keydb.cfg $out
  '';
}
