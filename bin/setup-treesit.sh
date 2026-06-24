#!/usr/bin/env bash
# Install missing tree-sitter grammars for this Emacs config.
set -euo pipefail
emacs -batch -l ~/.emacs.d/init.el -f my/install-all-treesit-grammars
