{ stdenv, unzip, fetchzip, ... }:

stdenv.mkDerivation {
  name = "keydb-eng";
  inherit unzip;
  src = fetchzip {
    url = "http://fvonline-db.bplaced.net/export/keydb_eng.zip";
    sha256 = "08q5zans05hvv7wk0jc9y5j4q1sf2916dbxbgmf0in3nvckrqi0g";
  };
  installPhase = ''
    cp $src/keydb.cfg $out
  '';
}
