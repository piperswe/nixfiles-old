{ config, pkgs, lib, fetchurl, ... }:
let
  dir = "${config.home.homeDirectory}/Music";
  ifLinuxAMD64 = lib.mkIf (pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64);
  secrets = import ./secrets.nix;
  ffmpeg = pkgs.ffmpeg-full.override {
    nonfreeLicensing = true;
    fdkaacExtlib = true;
  };
  aac-encoder = pkgs.writeScriptBin "aac-encoder" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    shopt -s globstar

    mkdir -p "$(dirname "$2")"
    nice ${ffmpeg}/bin/ffmpeg -y -i "$1" -vn -c:a libfdk_aac -vbr 5 -movflags +faststart -af aresample=resampler=soxr -ar 44100 "$2"
  '';
  mp3-encoder = pkgs.writeScriptBin "mp3-encoder" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    shopt -s globstar

    mkdir -p "$(dirname "$2")"
    nice ${ffmpeg}/bin/ffmpeg -y -i "$1" -vn -c:a libmp3lame -V 0 -movflags +faststart -af aresample=resampler=soxr -ar 44100 "$2"
  '';
  sync-ipod = pkgs.writeScriptBin "sync-music" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    shopt -s globstar

    IPOD="/media/pmc/PIPER'S IPO"

    ${pkgs.qtscrobbler}/bin/scrobbler -c ~/Music/qtscrob.conf -f -l "$IPOD/"
    ${pkgs.beets}/bin/beet splupdate
    ${pkgs.rsync}/bin/rsync -rpthu --inplace --delete --info=progress2 ~/Music/playlists/ "$IPOD/Playlists/"
    ${pkgs.rsync}/bin/rsync -rpthu --inplace --delete --info=progress2 ~/Music/ "$IPOD/Music/"
  '';
  sync-mediaserver = pkgs.writeScriptBin "sync-mediaserver" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    shopt -s globstar

    ${pkgs.rsync}/bin/rsync -avhP --delete --info=progress2 ~/Music/ root@media.psrv.hodgepodge.dev:/mediaserver/music/
  '';
  customMakemkv = pkgs.qt5.callPackage ./makemkv.nix { };
in
{
  #nixpkgs.overlays = ifLinuxAMD64 [
  #  (
  #    self: super: {
  #      vlc = super.vlc.override {
  #        libbluray = super.libbluray.override {
  #          withAACS = true;
  #          withBDplus = true;
  #        };
  #      };
  #    }
  #  )
  #];

  home.packages = with pkgs; [
    (ifLinuxAMD64 rubyripper)
    (ifLinuxAMD64 cdrdao)
    flac
    imagemagick
    (ifLinuxAMD64 customMakemkv)
    (ifLinuxAMD64 ccextractor)
    (ifLinuxAMD64 aac-encoder)
    (ifLinuxAMD64 mp3-encoder)
    (ifLinuxAMD64 sync-ipod)
    (ifLinuxAMD64 sync-mediaserver)
    pavucontrol
  ];

  services.syncthing.enable = ifLinuxAMD64 true;

  services.mpd = {
    enable = true;
    network.listenAddress = "any";
    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${config.home.homeDirectory}/Music/playlists";
    extraConfig = ''
      auto_update "yes"
    '';
  };
  services.mpdris2.enable = true;

  programs.fish.functions.ripcd = ifLinuxAMD64 {
    body = ''
      set TEMPDIR (mktemp -d)
      or exit 1
      pushd $TEMPDIR
      rrip_cli
      or { popd; exit 1 }
      beet import -t .
      or { popd; exit 1 }
      popd
    '';
  };

  programs.beets = {
    enable = false;
    settings = {
      directory = dir;
      library = "${dir}/musiclibrary.db";
      asciify_paths = true;
      import = {
        move = true;
        timid = true;
      };
      plugins = "fetchart embedart lyrics lastgenre chroma convert replaygain acousticbrainz mbsync mbcollection absubmit web bpd discogs badfiles smartplaylist playlist";
      lyrics.auto = true;
      absubmit.auto = true;
      thumbnails.auto = true;
      acoustid.apikey = secrets.acoustidKey;
      convert = {
        auto = false;
        never_convert_lossy_files = true;
        dest = "${config.home.homeDirectory}/MP3Music";
        format = "aac";
        formats = {
          aac = {
            command = "${aac-encoder}/bin/aac-encoder $source $dest";
            extension = "m4a";
          };
          mp3 = "${mp3-encoder}/bin/mp3-encoder $source $dest";
        };
      };
      replaygain.backend = "gstreamer";
      musicbrainz = {
        user = "piperswe";
        pass = secrets.musicbrainzPassword;
      };
      mbcollection = {
        auto = true;
        collection = "7a8bdef2-e937-42ac-b883-43b739b32798";
      };
      keyfinder.auto = true;
      playlist = {
        playlist_dir = "${dir}/playlists";
      };
      smartplaylist = {
        playlist_dir = "${dir}/playlists";
        playlists = [
          {
            name = "Monstercat.m3u";
            query = "album:Monstercat";
          }
          {
            name = "Not Monstercat.m3u";
            query = "^album:Monstercat";
          }
        ];
      };
    };
  };

  home.file = ifLinuxAMD64 (
    let
      keydb = pkgs.callPackage ./keydb-eng.nix { };
    in
    {
      ".config/aacs/keydb.cfg".source = keydb;
      ".MakeMKV/KEYDB.cfg".source = keydb;
      ".MakeMKV/keys_hashed.txt".source = ./keys_hashed.txt;
      ".config/rubyripper/settings".source = ./rubyripper.ini;
    }
  );
}
