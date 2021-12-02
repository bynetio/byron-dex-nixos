# Dex Nixos

### Updating flake

In order to update flake inputs, simply use below commands:

```bash
cd ~/dex-nixos
nix flake update
```

### Rebuilding flake with latest changes

To rebuild NixOS which is generated from the `flake.nix` file, use below commands as root:

```bash
cd ~/dex-nixos
nixos-rebuild switch --flake .
```

Note: Remember than any new files have to be staged first otherwise flake won’t register them and rebuilding will fail.

### Resources

* [Nix Flakes, Part 1: An introduction and tutorial](https://www.tweag.io/blog/2020-05-25-flakes)
* [Nix Flakes, Part 2: Evaluation caching](https://www.tweag.io/blog/2020-06-25-eval-cache)
* [Nix Flakes, Part 3: Managing NixOS systems](https://www.tweag.io/blog/2020-07-31-nixos-flakes)
* [Practical Nix Flakes](https://serokell.io/blog/practical-nix-flakes)
