# `:Lazy update` triage — 2026-09-24

Notes from sifting the update dump. Delete sections as you burn them down.
Environment facts used throughout: **nvim 0.12.5**, `vim.opt.shell = "nu"`.

---

## New and actually interesting

### auto-session can now save/restore ShaDa per session

`save_and_restore_shada = false` (default off, requires ≥ 0.11). Scopes command
line/search history, registers, marks, and globals _to the session_ instead of
sharing one global ShaDa across every project.

Caveat from the changelog: enabling it makes auto-session
`disable global shada at setup`. That's a real behavior change for anything that
expects cross-project registers/marks — including `nvim-neoclip`, which has its
own persistence, so check for double-bookkeeping before flipping it.

Note your `sessionoptions` already appends `globals` (`lua/plugins/sessions.lua:5`),
so some of that state is session-scoped today by a different mechanism.

- [ ] Decide: per-project history, yes or no?

## Cross-cutting: plenary.nvim is being archived

From its README:

> This repository is no longer actively maintained and will be officially
> archived soon. Critical bugs may still be addressed until **2026-06-30**.

That date has passed. Not an emergency — archived ≠ broken — but it's now a
frozen dependency. Your exposure:

| Consumer                    | Still needs plenary?                                          |
| --------------------------- | ------------------------------------------------------------- |
| `telescope.nvim`            | Yes, hard dependency                                          |
| `nvim-neoclip`              | Only via telescope (backends are `telescope.lua` / `fzf.lua`) |
| `auto-session` session-lens | No — supports `picker = "snacks"`                             |
| `tiny-code-action`          | **No longer** — upstream moved to `vim.system`                |
| `gitsigns`                  | No                                                            |

Path to dropping it entirely runs through **nvim-neoclip**, which has no
snacks backend. Everything else can already move off telescope.

- [x] `auto-session` -> `session_lens.picker = "snacks"`. Verified at runtime:
      `require("auto-session.pickers").picker_name` reports `snacks`.
- [x] `tiny-code-action` -> `opts.picker = "snacks"`.
- [ ] Replace neoclip, or accept telescope as a neoclip-only island. See below.

Both needed to be **explicit**, not just a dependency swap — each plugin
autodetects in an order that puts telescope first, and telescope stays installed
for neoclip either way:

| Plugin | Autodetect order | Source |
| --- | --- | --- |
| `auto-session` | `telescope -> fzf -> snacks -> select` | `pickers/init.lua:20` |
| `tiny-code-action` | `telescope -> fzf-lua -> snacks -> select -> buffer` | `picker.lua:25` |

`auto-session` also needed `load_on_setup = false`: it's telescope-only, and
`config.lua:366` warns on every startup if it's left on with another picker.

### Side effect, measured: telescope became a `start` plugin

Removing `"nvim-telescope/telescope.nvim"` from auto-session's `dependencies`
left `lua/plugins/registers.lua:10`'s bare `"telescope.nvim"` as the only
reference — a *short name*, not a repo spec. With no canonical spec anywhere,
lazy.nvim resolves it as a `start` plugin and loads it during startup instead
of on neoclip's `VeryLazy`.

**I flagged this as a regression. Measured, it isn't one.** Being a `start`
plugin costs exactly one line of startup work:

```
$ grep telescope /tmp/startuptime.log
041.338  000.086  000.086: sourcing .../telescope.nvim/plugin/telescope.lua
```

**0.086 ms.** 7 runs each way, total startup:

| Variant | Runs (ms) | Median |
| --- | --- | --- |
| `{ "nvim-telescope/telescope.nvim", lazy = true }` | 65.9 63.5 62.8 65.2 60.3 62.9 64.5 | 63.5 |
| no spec (telescope is `start`) | 63.9 68.9 64.8 65.4 61.3 60.2 61.9 | 63.9 |

Run-to-run noise is ±4 ms, so the difference is unmeasurable. `packadd` only
adds to `rtp` and sources `plugin/`; the expensive `require("telescope")` is
deferred to first use either way, and neoclip triggers that at `VeryLazy`
regardless. **Left it alone** — not worth a spec, especially if neoclip goes.

**Still worth knowing generally:** a bare `"foo.nvim"` in `dependencies` only
keeps its lazy semantics while some *other* spec names the full `owner/repo`.
Prune that spec and the load timing changes silently. Here it happens not to
matter; somewhere with a heavy `plugin/` directory it would.

---

## Replacing neoclip: `gbprod/yanky.nvim` is the way out

This is the last thing pinning telescope, and therefore plenary.

**[`gbprod/yanky.nvim`](https://github.com/gbprod/yanky.nvim)** has first-class
snacks support — it self-registers as a picker source when loaded after snacks,
giving you `Snacks.picker.yanky()`. Upstream's own lazy.nvim example:

```lua
{
  "gbprod/yanky.nvim",
  opts = {},
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<leader>p", function() Snacks.picker.yanky() end, mode = { "n", "x" },
      desc = "Open Yank History" },
  },
}
```

Why it's a clean trade for your setup:

- **No plenary, no telescope, no sqlite required.** Storage is
  `"shada" | "sqlite" | "memory"`, and **shada is the default** — persistence
  without a database. neoclip needs sqlite for the same thing.
- It's a superset: yank *ring* (cycle prior yanks with `<M-p>`/`<M-n>` after a
  put) on top of the history picker, plus put-with-reindent variants.
- Dropping neoclip drops telescope drops plenary. Three plugins to one, and the
  archived-dependency problem goes away entirely.

### Two things to check before committing to it

1. **`system_clipboard.sync_with_ring = true` is the default**, and it syncs on
   focus gain. Given your sibling change
   `DO NOT MERGE: fix(neoclip): disable to avoid unnecessary clipboard access`,
   that default is probably exactly what you don't want — it would reintroduce
   `+` register reads on every focus event. Set `system_clipboard = {
   sync_with_ring = false }` and evaluate from there.

   For reference, neoclip is *not* the polling culprit by default:
   `continuous_sync = false`, and it only hooks `TextYankPost`,
   `VimLeavePre`, and `RecordingLeave` (`lua/neoclip.lua:10-17`). So whatever
   drove that change may follow you to yanky unless you turn this off.

2. **Macro history has no equivalent.** neoclip records macros via
   `RecordingLeave` (`enable_macro_history = true`, default on) and replays them
   from the picker. yanky is yanks only. If you use that, it's a real loss.

### Alternatives considered and rejected

- **`snacks.picker` alone** — no yank-history source. It has `registers`, which
  shows *current* register contents, not history. Sources are
  `buffers/diagnostics/diff/explorer/files/gh/git/grep/help/icons/lazy/lines/lsp/proc/qf/recent/scratch/system/treesitter/vim`.
- **neoclip's `fzf-lua` backend** — trades telescope for fzf-lua, which you
  don't otherwise use. Sideways move, and plenary stays.
- **Roll your own** — `TextYankPost` into a ring plus `Snacks.picker`. Maybe 40
  lines, zero dependencies, but you'd own persistence and regtype handling.

- [ ] Try yanky with `sync_with_ring = false`?

---

## `fzf-lua` vs `snacks.picker`: I benchmarked it, stay on snacks

You moved off telescope because snacks was *so much faster*. That premise
doesn't transfer to fzf-lua — snacks is already at parity with the native
binary.

### Speed: a tie, and snacks wasn't supposed to win

500,000 synthetic `mozilla-central`-shaped paths, same queries both ways.
fzf 0.74.4 (`--filter`, native Go, multithreaded) vs snacks'
`picker.core.matcher` (LuaJIT, single-threaded, scoring every item):

| Query | Hits | `fzf --filter` | `snacks` matcher |
| --- | --- | --- | --- |
| `wgpu` | 205,830 | 0.15 s | 0.158 s |
| `webgpu` | 106,609 | 0.09 s | 0.109 s |
| `rndbuf` | 77 | 0.03 s | 0.077 s |

fzf wins ~2x on the highly-selective query and ties on the broad ones — all far
under the perceptual threshold, at 500k candidates. Caveat: this is raw match
throughput, not IO or render; both stream asynchronously in real use. But
there's no "fzf is the fast one" story here. Your telescope pain was
telescope's overhead, not Lua matching.

### Inline `rg` refinement: snacks is actually the better one

Both use a `--` separator in the prompt. The difference is what's past it:

- **snacks** tokenizes and appends *arbitrary* `rg` args
  (`Snacks.picker.util.parse`, `picker/util/init.lua:286`, spliced at
  `source/grep.lua:73`). So `Snacks.bufdelete -- -t lua --no-ignore` works, as
  does any flag `rg` accepts.
- **fzf-lua** (`live_grep_glob`) parses past `--` and reconstructs it
  specifically into `--iglob=...`. Globs only.

So the feature you named is the one you'd *lose* resolution on.

### Ecosystem, measured against your actual plugin list

Abstract ecosystem arguments don't decide this; your four consumers do:

| Plugin | telescope | snacks | fzf-lua | `vim.ui.select` |
| --- | --- | --- | --- | --- |
| `nvim-neoclip` | yes | **no** | **yes** | no |
| `yanky.nvim` | yes | **yes** | **no** | yes |
| `auto-session` | yes | yes | yes | yes |
| `tiny-code-action` | yes | yes | yes | yes |

The two clipboard plugins have **disjoint** support outside telescope. That's
the whole fork in the road:

- **fzf-lua** -> keep neoclip, keep macro history, drop telescope + plenary.
- **snacks** -> switch to yanky, lose macro history, drop telescope + plenary.

Both get you off plenary. Neither lets you have both.

### One thing that would have made migration easy, and one that doesn't

You use snacks for **the picker and nothing else** — 21 `snacks.picker`
references, zero other modules. So it isn't a suite you're locked into; swapping
it for fzf-lua would be a clean 1:1 trade, not a teardown. Migration is cheap.

It's just not *worth* it. You'd be paying a full picker migration and a
downgrade in grep refinement to buy back macro history that you called "nice,
though infrequently used." If macro replay turns out to matter more than you
expect, the cheaper fallback is keeping neoclip as a telescope-only island
(telescope's whole startup cost is 0.086 ms, measured above) rather than
re-pickering everything.

**Recommendation:** stay on snacks, take yanky, accept the macro-history loss.

- [ ] Agree? Then wire up yanky and drop neoclip + telescope + plenary.

---

## Stale bits in your own config, noticed in passing

- [x] `lua/plugins/git.lua` — gitsigns used `requires = { … }`, a **packer**
      key that lazy.nvim silently ignores (it reads `dependencies`). Converted to
      `dependencies`, and dropped `nvim-lua/plenary.nvim` from it: gitsigns has zero
      `plenary` references left in its source.
- [x] `lua/plugins/languages.lua` — dropped the dead `plenary.nvim` dependency
      from `tiny-code-action`. Verified: zero `plenary` references anywhere in
      `~/.local/share/nvim/lazy/tiny-code-action.nvim`, since it moved to
      `vim.system`.
- `blink.cmp` is pinned `v1.*` and sits at `v1.10.2`, the newest tag upstream —
  the pin isn't holding you back, no v2 exists. Nothing to do.

---

## Found while verifying: `sessionoptions` is missing `localoptions`

`:checkhealth auto-session` says:

> `vim.o.sessionoptions` should contain 'localoptions' to make sure the highlighting
> of the restored buffers is correct

Pre-existing, unrelated to this update batch. `lua/plugins/sessions.lua:2` does
`:remove("options")` (a no-op — nvim's default `sessionoptions` doesn't include
it) but never adds `localoptions`, so buffer-local options like `filetype` and
`syntax` don't survive a session restore. Cheap fix if the symptom sounds
familiar:

```lua
vim.opt.sessionoptions:append("localoptions")
```

- [ ] Add `localoptions`?
