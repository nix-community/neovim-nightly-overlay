let
  sources = import ./nix/sources.nix;
  nixpkgs = sources."nixos-unstable";
  pkgs = import nixpkgs {};
  emacs-pgtk-nativecomp = sources."emacs-pgtk-nativecomp";
in
{
  ci = (import ./nix {}).ci;
  emacsGccPgtk = builtins.foldl' (drv: fn: fn drv)
    pkgs.emacs
    [

      (drv: drv.override { srcRepo = true; })

      (
        drv: drv.overrideAttrs (
          old: {
            name = "emacs-pgtk-native-comp";
            version = "28.0.50";
            src = pkgs.fetchFromGitHub {
              inherit (emacs-pgtk-nativecomp) owner repo rev sha256;
            };

            configureFlags = old.configureFlags
            ++ [ "--with-pgtk" ];


            patches = [
              (
                pkgs.fetchpatch {
                  name = "clean-env.patch";
                  url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/clean-env.patch";
                  sha256 = "0lx9062iinxccrqmmfvpb85r2kwfpzvpjq8wy8875hvpm15gp1s5";
                }
              )
              (
                pkgs.fetchpatch {
                  name = "tramp-detect-wrapped-gvfsd.patch";
                  url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/tramp-detect-wrapped-gvfsd.patch";
                  sha256 = "19nywajnkxjabxnwyp8rgkialyhdpdpy26mxx6ryfl9ddx890rnc";
                }
              )
            ];

            postPatch = old.postPatch + ''
              substituteInPlace lisp/loadup.el \
              --replace '(emacs-repository-get-version)' '"${emacs-pgtk-nativecomp.rev}"' \
              --replace '(emacs-repository-get-branch)' '"master"'
            '';

          }
        )
      )
      (
        drv: drv.override {
          nativeComp = true;
        }
      )
    ];
}
