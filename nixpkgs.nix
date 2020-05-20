# Using a separate nixpkgs for packages I'm building because, for
# example, cargoSha256 varies with nixpkgs version.
let version = "0fc9fc05bc53d19fc10cb1dc8674b68f7fe0de75";
in import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${version}.tar.gz") { }
