{
  lib,
  pkgs,
  neovim-src,
  ...
}:
lib.pipe "${neovim-src}/cmake.deps/deps.txt" [
  builtins.readFile
  (lib.splitString "\n")
  (map (builtins.match "([A-Z0-9_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*"))
  (lib.remove null)
  (lib.flip builtins.foldl' { } (
    acc: matches:
    let
      name = lib.toLower (builtins.elemAt matches 0);
      key = lib.toLower (builtins.elemAt matches 1);
      value = lib.toLower (builtins.elemAt matches 2);
    in
    acc
    // {
      ${name} = acc.${name} or { } // {
        ${key} = value;
      };
    }
  ))
  (builtins.mapAttrs (lib.const pkgs.fetchurl))
]
