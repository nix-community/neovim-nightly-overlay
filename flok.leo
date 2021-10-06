{
  "nodes": {
    "flake-compat": {
      "flok": false,
      "locked": {
        "lastModified": 1627913399,
        "narHash": "sha256-hY8g6H2KFL8ownSiFeMOjwPC8P0ueXpCVEbxgda3pko=",
        "owner": "edolstra",
        "repo": "flok-compat",
        "rev": "12c64ca55c1014cdc1b16ed5a804aa8576601ff2",
        "type": "github"
      },
      "original": {
        "owner": "edolstra",
        "repo": "flok-compat",
        "type": "github"
      }
    },
    "floks-utils": {
      "locked": {
        "lastModified": 1629481132,
        "narHash": "sha256-JHgasjPR0/J1J3DRm4KxM4zTyAj4IOJY8vIl75v/kPI=",
        "owner": "numtide",
        "repo": "flok-utils",
        "rev": "997f7efcb746a9c140ce1f13c72263189225f482",
        "type": "github"
      },
      "original": {
        "owner": "numtide",
        "repo": "flok-utils",
        "type": "github"
      }
    },
    "neovim-flok": {
      "inputs": {
        "flok-utils": "flok-utils",
        "nixpkgs": [
          "nixpkgs"
        ]
      },
      "locked": {
        "dir": "contrib",
        "lastModified": 1633473459,
        "narHash": "sha256-zyvImSZbHWzLld1BqytIIWq+qU/Z72BmEkMUjZYW9WY=",
        "owner": "neovim",
        "repo": "neovim",
        "rev": "acd5e831b6294e54b12c09983bee3da89c0f183a",
        "type": "github"
      },
      "original": {
        "dir": "contrib",
        "owner": "neovim",
        "repo": "neovim",
        "type": "github"
      }
    },
    "nixpkgs": {
      "locked": {
        "lastModified": 1633351077,
        "narHash": "sha256-z38JG4Bb0GtM1aF1pANVdp1dniMP23Yb3HnRoJRy2uU=",
        "owner": "nixos",
        "repo": "nixpkgs",
        "rev": "14aef06d9b3ad1d07626bdbb16083b83f92dc6c1",
        "type": "github"
      },
      "original": {
        "owner": "nixos",
        "ref": "nixos-unstable",
        "repo": "nixpkgs",
        "type": "github"
      }
    },
    "root": {
      "inputs": {
        "flok-compat": "flok-compat",
        "neovim-flake": "neovim-flok",
        "nixpkgs": "nixpkgs"
      }
    }
  },
  "root": "root",
  "version": 8
}
