# actmon

Terminal Activity Monitor for macOS. One-shot snapshot of CPU, memory, and energy use — with bar charts. Works as a CLI and as a Claude Code slash command.

```
Activity Monitor — 21:24:51

  Load     1m  2.62   ▕████░░░░░░░░░░░░░░░░▏  21%
           5m  3.44   ▕█████░░░░░░░░░░░░░░░▏  28%
           15m 1.96   ▕███░░░░░░░░░░░░░░░░░▏  16%
  CPU      ▕█████▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▏  █ user 13.27% · ▒ sys 13.55% · idle 73.16%
  Memory   ▕███████████████████████▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒░░▏  █ app 10G · ▓ wired 3G · ▒ compressed 4G · ░ free 1G  /  18G
  Swap     ▕█████████████████████░░░░░░░░░░░░░░░░░░░▏  1.6 / 3.0 GB (53%)
  Hardware Mac15,6 · 12 cores · Uptime 4:58

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
actmon                              full dashboard, top 10 per section
actmon --top 5                      top 5 per section
actmon -n 5                         short form for --top
actmon --cpu                        CPU section only
actmon --memory                     memory section only
actmon --energy                     energy section only
actmon --cpu --energy               combine sections
actmon --filter 'chrome|safari'     only browser-ish processes (case-insensitive regex)
actmon --filter '^WindowServer$'    exact-match a single process
actmon --cpu --threshold 5          CPU section, hide anything under 5%
actmon --mem-min 500                hide memory rows under 500 MB
actmon --filter chrome --top 5      top 5 chrome-ish rows per section
actmon --json                       machine-readable JSON snapshot
actmon --no-color                   disable ANSI color (auto-disabled when piped)
actmon --help                       full usage
```

Metric flags are additive. With no flag, all three sections are shown. The system summary header is always shown.

`--filter` and `--threshold` (plus `--cpu-min` / `--mem-min` / `--energy-min`) apply before `--top`, so the top-N you see is the top-N of what survived filtering. `--threshold` broadcasts to all sections (its unit changes per section: %CPU, MB, raw power); the per-section flags override it.

### JSON output

`--json` emits a single JSON object instead of the dashboard — useful for piping into `jq`, scripts, or LLMs that would rather not parse ASCII bars:

```sh
actmon --json | jq '.top_cpu[0]'
actmon --json --memory --top 3 | jq '.top_memory[].command'
```

Header keys (`timestamp`, `host`, `load`, `cpu`, `memory`, `swap`) are always present. The `top_cpu` / `top_memory` / `top_energy` arrays are included only when their section is enabled, following the same `--cpu` / `--memory` / `--energy` rules as the dashboard.

### Highlighting

When `actmon` is run in a terminal, stressed rows light up to draw the eye — calm machines render with no color at all. The current thresholds:

- **Red** (critical): swap > 75%, load avg > `ncpu`, free memory < 5%, or any process > 50% CPU
- **Yellow** (warning): swap > 50%, load avg > 0.75 × `ncpu`, free memory < 15%, or any process > 25% CPU

Color is auto-disabled when stdout isn't a TTY (e.g. when piped), when `NO_COLOR` is set in the environment, or when `--no-color` is passed.

### Process names

Process names come from `ps` (full executable path) rather than `top -stats command`, which for some helper binaries reports just a version string (e.g. `2.1.139` for Claude Code's launcher shim). `actmon` walks up parent path segments, skipping generic containers like `Versions`/`MacOS`/`Contents`, until it finds a name with letters — so `claude` shows up instead of `2.1.139`.

## In Claude Code

After `install.sh` there are two ways to run it inside Claude Code, and they're meant for different things:

|   | What happens | Token cost | Best for |
|---|---|---|---|
| `!actmon` | Claude Code's `!` prefix runs the command directly in your shell. Output appears in the chat. Claude isn't invoked. | 0 | **The primary use case** — you just want to glance at the dashboard. |
| `/actmon` | Loads the slash command, which has Claude run the CLI via its Bash tool. Output is shown, and Claude has it in context. | small | Follow-up questions: *"what's eating my CPU?"*, *"is process 671 Chrome?"*, *"should I kill the top one?"* |

Rule of thumb: **`!actmon` for monitoring, `/actmon` for asking about what you see.**

Flags work identically in both — anything after the command name passes straight through to the CLI:

```
!actmon --memory --top 5
/actmon --cpu --energy --top 3
```

The slash command is intentionally a one-liner that runs `~/.claude/scripts/actmon $ARGUMENTS` and displays the output verbatim — Claude doesn't reformat it, so the slash-command overhead is small even when you do use it.

## Requirements

- macOS (uses BSD `top -stats`)
- bash 3.2+, `awk`, `sed`, `sysctl`, `vm_stat`, `uptime` — all pre-installed on every Mac

## Roadmap

Not in v0.1, contributions welcome:

- `--watch` / auto-refresh (for now: `/loop 5s /actmon` in Claude Code)
- Disk I/O + network per process (macOS makes per-process network attribution awkward)
- Linux/BSD compat (`top -stats` is mac-only)
- Homebrew formula

## Contributing

PRs and issues welcome. The whole tool is one Bash script (`bin/actmon`, ~600 lines) — easy to read, easy to change.

## License

MIT — see [LICENSE](LICENSE).
