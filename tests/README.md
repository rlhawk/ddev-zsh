# ddev-zsh tests

This test suite follows the lifecycle used by the DDEV add-on template:

1. Create a clean temporary DDEV project.
2. Install the add-on from a local repository or its GitHub release.
3. Restart the project so package and image changes are applied.
4. Run add-on-specific health checks.
5. Delete the temporary project.

## Coverage

The health checks verify:

- `ddev zsh-doctor`
- Zsh, fzf, and Starship executables
- Antidote and Oh My Zsh libraries
- The writable `/mnt/ddev-zsh` mount
- The configured history file
- Persistent state environment variables
- A noninteractive `ddev zsh` invocation

## Run locally

From the repository root:

```bash
bats tests/test.bats
```
