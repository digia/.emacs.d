# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A personal Emacs 30.2 configuration (terminal-only Homebrew build, macOS aarch64) using Evil for modal editing and Emacs idioms for everything else. The Neovim config at `~/Code/digia/nvim` is the source of truth for keybindings and workflow patterns — keybindings should match for muscle memory, but prefer Emacs-native solutions for features.

This repo is symlinked to `~/.emacs.d/`. Emacs uses the same directory for both config and runtime data — only the config files are tracked; runtime data is gitignored.

## Testing

```sh
# Verify config loads without errors
emacs --batch -l ~/.emacs.d/init.el --eval '(kill-emacs 0)'
```

No test framework — configuration is manually tested in interactive Emacs.

## Architecture

### Module Loading Order (init.el)

The loading order is critical due to Elpaca's async package installation:

```
early-init.el          → GC max, UI suppression, disable package.el
Elpaca bootstrap       → v0.12 installer + use-package integration
[elpaca-wait]          → use-package ready
core.el                → Built-in settings only, no packages
evil-setup.el          → Evil + general.el (defines my-leader-def)
[elpaca-wait]          → LOAD BARRIER: my-leader-def must exist
completion.el          → Vertico stack, uses my-leader-def
ui.el                  → Theme, modeline, uses my-leader-def
git.el                 → Magit + diff-hl, uses my-leader-def
lsp.el                 → Eglot + Corfu, uses my-leader-def
tools.el               → vterm, undo-fu-session, terraform, kubel
[elpaca-wait]          → All packages installed before user interaction
GC restore             → 16MB threshold for normal operation
```

The second `elpaca-wait` after `evil-setup.el` is **load-bearing**. `my-leader-def` (a `general-create-definer` macro) is defined in evil-setup.el and used in every subsequent module. Without this barrier, modules fail with undefined function errors. `general.el` itself uses `:ensure (:wait t)` to force synchronous installation within evil-setup.el.

### Package Sources

- **Built-in (`:ensure nil`)**: which-key, eglot, flymake, recentf, savehist, paren, whitespace
- **GitHub recipes**: tokyonight-themes (xuchengpeng), indent-bars (jdtsmith)
- **MELPA**: everything else
- **Transient**: explicitly installed from MELPA to override Emacs 30's built-in 0.7.x (magit requires >= 0.12)

### Keybinding Structure

Leader key is SPC via general.el, bound in normal/visual/motion states with `:keymaps 'override`.

| Prefix | Concept | Defined in |
|--------|---------|------------|
| `SPC y` | yank/clipboard | evil-setup.el |
| `SPC f` | find files | completion.el |
| `SPC s` | search | completion.el |
| `SPC g` | git | git.el |
| `SPC v` | LSP | lsp.el |
| `SPC u` | toggle | ui.el |
| `SPC SPC` | double-leader (repeat cmd, reload) | evil-setup.el |

`C-h/j/k/l` override Emacs help prefix for window navigation (help remapped to F1). This is set only in Evil normal/motion state maps to preserve C-h in non-Evil contexts.

### Custom Mode-line (ui.el)

Hand-built `mode-line-format` with Evil state-dependent faces on the filename section (blue normal, green insert, purple visual). Path is relative to project root. No powerline or external mode-line packages. Uses `mode-line-format-right-align` (Emacs 30) for right-side sections.

### Terminal Cursor (evil-setup.el)

DECSCUSR escape sequences sent via `send-string-to-terminal` on Evil state entry hooks — block cursor in normal, bar in insert, underline in replace. Required because terminal Emacs doesn't translate `cursor-type` to terminal escape codes. Includes `server-after-make-frame-hook` for daemon mode.

### Clipboard (core.el)

Terminal Emacs on macOS requires explicit `pbcopy`/`pbpaste` integration via `interprogram-cut-function`/`interprogram-paste-function`. All kill/yank operations sync with the system clipboard.

## Known Circle-Back Items

- Trailing whitespace: should display as middot (·) in comment color, but `whitespace-mode` `space-mark` affects all spaces not just trailing
- `consult-fd` as file finder: async separator (`#`) prevents showing all files immediately — `project-find-file` used as fallback
- Powerline arrow separators in mode-line: Unicode arrows didn't render correctly in terminal
- Fill column 120+ "wall" effect: Emacs only supports a single `display-fill-column-indicator` column
- `[e`/`]e` conflict: evil-collection unimpaired (move-text) vs LSP (diagnostic error nav)
