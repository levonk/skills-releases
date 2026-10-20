---
description: Reusable guard for posting GitHub issue and PR bodies via gh CLI — prevents the two corruption modes (literal \n and stripped backticks) that have shipped broken posts in the wild
---

## CRITICAL — How to post these bodies to GitHub (read before any `gh` call)

The template below contains markdown backticks (`` ` `` and triple-fence ``` ``` ```), shell-style `$VARS` (`$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`), and real newlines. If you pass it to `gh` the wrong way, GitHub stores garbage. Two failure modes have shipped broken PRs/issues in the wild:

1. **Literal `\n` in the body** — happens when you reconstruct the body as a single-line string with `\n` escape sequences (e.g. an LLM-emitted string literal) and pass it to `gh --body "..."`. The `\n` is stored verbatim as two characters, not a newline. The whole post becomes one unreadable line.
2. **Stripped code spans + empty variables** — happens when you feed the body through an unquoted shell heredoc (`cat <<EOF` instead of `cat <<'EOF'`) or `echo "..."`. Backticks get command-substituted (`` `flake.nix` `` runs as a command → empty), and `$UPSTREAM_OWNER` is expanded by the shell to empty.

**Always do this, no exceptions:**

1. Substitute the placeholders by **text replacement** (not shell expansion): `$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`, and any `<issue-number>` / `<platform>` / `<project-name>` / `<feature-name>` placeholders. Use `sed -i`/`perl -pi -e` or edit the file in your editor tool — never let bash expand `$UPSTREAM_OWNER`.
2. Write the final body to a **file** (e.g. `/tmp/pr-body.md` or `/tmp/issue-body.md`).
3. Post with `--body-file`, never `--body`:
   ```bash
   gh pr create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/pr-body.md
   gh issue create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/issue-body.md
   ```
4. Before posting, sanity-check the file: `grep -c '\\n' /tmp/pr-body.md` must return `0` (no literal backslash-n), and `grep -n '`'` must show the backtick code spans intact.

**Never** use `gh ... --body "$BODY"` with an inline string. **Never** use an unquoted heredoc to build the body. The `--body-file` path is the only one that survives multi-line markdown with backticks and `$` intact.


---

<!-- Variant: nixpkgs contribution PR (project not in nixpkgs) -->
<!-- This PR is opened to NixOS/nixpkgs, NOT to the upstream project repo. -->
<!-- The audience is nixpkgs maintainers — do NOT explain Nix concepts. -->
<!-- This is a departure from the project-owner PR/issue templates which educate about Nix. -->

<!-- Template body follows. Copy everything below this comment as the PR body. -->

---

title: $PROJECT: init at $VERSION

---

## Description

Add `$PROJECT` to nixpkgs.

$DESCRIPTION

## What is this?

$PROJECT is a tool from [$UPSTREAM_OWNER/$UPSTREAM_REPO](https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO).
The upstream project already has a working in-repo Nix flake
(https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO) which was used as the
reference for this packaging.

## Things done

<!-- Mirrors nixpkgs's own PR template — answer every checkbox truthfully. -->

- Built on platform:
  - [ ] x86_64-linux
  - [ ] aarch64-linux
  - [ ] x86_64-darwin
  - [ ] aarch64-darwin
- [ ] Tested, as applicable:
  - [NixOS test(s)](https://nixos.org/manual/nixos/unstable/index.html#sec-nixos-tests) in [nixos/tests](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests)
  - [Package tests](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#package-tests) at `passthru.tests`
- [ ] Ran `nixpkgs-review` on this PR
- [ ] Tested basic functionality of all binary files (usually in `./result/bin/`)
- [ ] Fits [CONTRIBUTING.md](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md), [pkgs/README.md](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md), [maintainers/README.md](https://github.com/NixOS/nixpkgs/blob/master/maintainers/README.md) and other READMEs

## Testing

The package was tested by:

1. Building: `nix-build -A $PROJECT`
2. Running: `result/bin/$PROJECT --version`
3. The in-repo flake at https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO
   also validates the build via CI

## Maintainer

I have added myself to `maintainers/maintainer-list.nix` in a separate commit
(`maintainers: add <handle>`, before the package commit).

## Disclosure

<!-- REQUIRED by nixpkgs's Automation/AI policy — do NOT remove, even though -->
<!-- the global no-attribution rule normally forbids this. The exception is -->
<!-- scoped to the nixpkgs PR only. Fill in the actual tool and model. -->
Parts of this contribution were prepared with assistance from an AI coding
tool (<tool> (<model>)). The changes were reviewed before submission; see the
`Assisted-by:` trailers on the commits.

<!-- BEGIN conditional: Superset Note -->
<!-- INCLUDE this section ONLY when the in-repo flake also exposes a #nixpkgs -->
<!-- output (add_nixpkgs_output=true from Step 11b). This tells nixpkgs -->
<!-- maintainers that the upstream project's flake already wraps this package. -->
<!-- If add_nixpkgs_output=false, DELETE this entire conditional block. -->

## Note

The upstream project's in-repo flake also exposes a `#nixpkgs` output that
wraps this nixpkgs package, giving users the choice between the prebuilt
release binary (`#prebuilt`), a from-source build (`#source`), and the
nixpkgs-packaged version (`#nixpkgs`). The two coexist — this PR makes the
package available to all Nix users via `nix profile add nixpkgs#$PROJECT`,
not just those who know about the in-repo flake.

<!-- END conditional: Superset Note -->
