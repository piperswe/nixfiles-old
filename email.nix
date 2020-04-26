{ config, pkgs, ... }:

{
  programs.password-store.enable = true;
  programs.neomutt.enable = true;
  programs.mbsync.enable = true;
  programs.notmuch.enable = true;

  accounts.email.accounts.fastmail = {
    address = "contact@piperswe.me";
    aliases = [
      "piperswe@gmail.com"
      "piper@conduitim.pl"
      "piper@hodgepodge.dev"
    ];
    imap = {
      host = "imap.fastmail.com";
      port = 993;
      tls.enable = true;
    };
    neomutt.enable = true;
    mbsync.enable = true;
    notmuch.enable = true;
    primary = true;
    realName = "Piper McCorkle";
    smtp = {
      host = "smtp.fastmail.com";
      port = 465;
      tls.enable = true;
    };
    userName = "contact@piperswe.me";
    passwordCommand = "${pkgs.pass}/bin/pass Email/Fastmail";
  };
}
