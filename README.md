# actmon

Terminal Activity Monitor for macOS. One-shot snapshot of CPU, memory, and energy use — with bar charts. Works as a CLI and as a Claude Code slash command.

```
Activity Monitor — 21:24:51

  Load       2.62, 3.44, 1.96
  CPU        13.27% user, 13.55% sys, 73.16% idle
  Memory     17G used · 177M free  ·  18.0 GB total
  Swap       1.6 / 3.0 GB used
  Hardware   Mac15,6 · 12 cores  ·  Uptime 4:58

TOP CPU
  25093    Chrome Helper (GPU)        24.4%  ████████████████████
  414      WindowServer               13.5%  ███████████░░░░░░░░░
  0        kernel_task                11.7%  █████████░░░░░░░░░░░
  36758    Linear Helper (R           11.0%  █████████░░░░░░░░░░░
  ...

TOP MEMORY
  671      Arc                         739M  ████████████████████
  1710     Browser Helper              666M  ██████████████████░░
  414      WindowServer                654M  █████████████████░░░
  ...

TOP ENERGY
  414      WindowServer                42.6  ████████████████████
  1710     Browser Helper              21.5  ██████████░░░░░░░░░░
  25093    Chrome Helper (GPU)         20.5  █████████░░░░░░░░░░░
  ...
```

## Why

`top` is dense. Activity Monitor.app is a separate window. `actmon` is a one-shot snapshot you read at a glance from your terminal — or call from Claude Code with `/actmon`.

## Install

```sh
git clone https://github.com/kejerial/actmon.git
cd actmon
./install.sh
```

That creates three symlinks:

| Symlink | Purpose |
|---|---|
| `~/.local/bin/actmon` | the CLI in your `PATH` |
| `~/.claude/scripts/actmon` | stable path the slash command calls |
| `~/.claude/commands/actmon.md` | the `/actmon` slash command itself |

If `~/.local/bin` isn't on your `PATH`, `install.sh` prints the line to add.

Uninstall with `./uninstall.sh` — only removes the symlinks `install.sh` created.

## Usage

```
actmon                       full dashboard, top 10 per section
actmon --top 5               top 5 per section
actmon -n 5                  short form for --top
actmon --cpu                 CPU section only
actmon --memory              memory section only
actmon --energy              energy section only
actmon --cpu --energy        combine sections
actmon --help                full usage
```

Metric flags are additive. With no flag, all three sections are shown. The system summary header is always shown.

## In Claude Code

After `install.sh`, type `/actmon` in any Claude Code session. The slash command is a thin wrapper around the CLI, so flags pass through:

```
/actmon
/actmon --memory --top 5
/actmon --cpu --energy
```

Output is shown verbatim — Claude doesn't reformat it, so each call costs near-zero tokens.

## Requirements

- macOS (uses BSD `top -stats`)
- bash 3.2+, `awk`, `sed`, `sysctl`, `vm_stat`, `uptime` — all pre-installed on every Mac

## Roadmap

Not in v0.1, contributions welcome:

- `--watch` / auto-refresh (for now: `/loop 5s /actmon` in Claude Code)
- Disk I/O + network per process (macOS makes per-process network attribution awkward)
- Linux/BSD compat (`top -stats` is mac-only)
- Color output / `--no-color`
- Homebrew formula

## Contributing

PRs and issues welcome. The whole tool is one Bash script (`bin/actmon`, ~160 lines) — easy to read, easy to change.

## License

MIT — see [LICENSE](LICENSE).
