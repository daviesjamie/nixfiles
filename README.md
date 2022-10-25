# Nixfiles

This repository contains configuration for the Nix systems in my life.

## Bootstrapping

### Home Manager

Assuming Nix is installed, a home-manager configuration can be bootstrapped by running the following from the root of this repo:

```
$ nix --experimental-features 'nix-command flakes' build --no-link .#homeConfigurations.jagd.activationPackage
$ "$(nix --experimental-features 'nix-command flakes' path-info .#homeConfigurations.jagd.activationPackage)"/activate
```

After running these commands, the `home-manager` CLI tool will be installed and available - so any further updates can be made with the usual `home-manager` CLI:

```
# Build the configuration
$ home-manager build --flake '.#jagd'

# Activate the configuration (building if necessary)
$ home-manager switch --flake '.#jagd'

# List configuration generations
$ home-manager generations
```

### Nix-Darwin

Assuming Nix is installed, a nix-darwin configuration can be bootstrapped by running the following from the root of this repo:

```
$ nix --experimental-features 'nix-command flakes' build --no-link .#darwinConfigurations.makani.config.system.build.toplevel
$ "$(nix --experimental-features 'nix-command flakes' path-info .#darwinConfigurations.makani.config.system.build.toplevel)"/sw/bin/darwin-rebuild switch --flake .#makani
```

After running these commands, the `darwin-rebuild` CLI tool will be installed and available - so any further updates can be made with the usual `darwin-rebuild` CLI:

```
# Build the configuration
$ darwin-rebuild build --flake '.#makani'

# Activate the configuration (building if necessary)
$ darwin-rebuild switch --flake '.#makani'

# List configuration generations
$ darwin-rebuild generations
```
