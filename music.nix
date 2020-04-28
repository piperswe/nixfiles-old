{ config, pkgs, ... }:

let dir = "${config.home.homeDirectory}/Music";
    secrets = import ./secrets.nix;
in {
  home.packages = [
    pkgs.rubyripper
    pkgs.cdrdao
    pkgs.flac
    pkgs.imagemagick
  ];

  home.file.".config/rubyripper/settings".source = ./rubyripper.ini;

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
      plugins = "fetchart embedart lyrics lastgenre chroma convert replaygain acousticbrainz thumbnails mbsync mbcollection absubmit web bpd discogs badfiles smartplaylist playlist";
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
            command = "${dir}/encode.sh $source $dest";
            extension = "m4a";
          };
          mp3 = "${dir}/encode-mp3.sh $source $dest";
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
