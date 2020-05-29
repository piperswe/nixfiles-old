with import ./nixpkgs.nix;
stdenv.mkDerivation rec {
  pname = "clj-kondo";
  version = "2020.04.05";

  reflectionJson = fetchurl {
    name = "reflection.json";
    url = "https://raw.githubusercontent.com/borkdude/${pname}/v${version}/reflection.json";
    sha256 = "1m6kja38p6aypawbynkyq8bdh8wpdjmyqrhslinqid9r8cl25rcq";
  };

  src = fetchurl {
    url = "https://github.com/borkdude/${pname}/releases/download/v${version}/${pname}-${version}-standalone.jar";
    sha256 = "0k9samcqkpkdgzbzr2bpixf75987lsabh97101v1fg12qvjhf187";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/java
    cp $src $out/share/java/clj-kondo.jar

    makeWrapper ${jre}/bin/java $out/bin/clj-kondo \
      --add-flags "-jar $out/share/java/clj-kondo.jar"
  '';

  meta = with lib; {
    description = "A linter for Clojure code that sparks joy.";
    homepage = "https://github.com/borkdude/clj-kondo";
    license = licenses.epl10;
    platforms = jre.meta.platforms;
    maintainers = with maintainers; [ jlesquembre bandresen ];
  };
}
