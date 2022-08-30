# Nixfiles

This repository contains configuration for the Nix systems in my life.

## Bootstrapping

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
