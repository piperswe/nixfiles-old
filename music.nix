{ config, pkgs, fetchurl, ... }:

let dir = "${config.home.homeDirectory}/Music";
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
sync-music = pkgs.writeScriptBin "sync-music" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail
  shopt -s globstar

  IPOD="/media/pmc/PIPER'S IPO"

  ${pkgs.qtscrobbler}/bin/scrobbler -c ~/Music/qtscrob.conf -f -l "$IPOD/"
  ${pkgs.beets}/bin/beet splupdate
  ${pkgs.rsync}/bin/rsync -rpthu --inplace --delete --info=progress2 ~/Music/playlists/ "$IPOD/Playlists/"
  ${pkgs.rsync}/bin/rsync -rpthu --inplace --delete --info=progress2 ~/Music/ "$IPOD/Music/"
'';
in {
  home.packages = [
    pkgs.rubyripper
    pkgs.cdrdao
    pkgs.flac
    pkgs.imagemagick
    pkgs.makemkv
    pkgs.ccextractor
    aac-encoder
    mp3-encoder
    sync-music
  ];

  home.file.".config/rubyripper/settings".source = ./rubyripper.ini;

  services.syncthing.enable = true;

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${config.home.homeDirectory}/Music/playlists";
  };
  services.mpdris2 = {
    enable = true;
    mpd.musicDirectory = "${config.home.homeDirectory}/Music";
  };

  programs.fish.functions.ripcd = {
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
    enable = true;
    settings = {
      directory = dir;
      library = "${dir}/musiclibrary.db";
      asciify_paths = true;
      import.move = true;
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
}
