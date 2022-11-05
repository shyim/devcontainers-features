# Features

This project **Features** is a set of reusable 'features'. Quickly add a tool/cli to a development container.

*Features* are self-contained units of installation code and development container configuration. Features are designed to install atop a wide-range of base container images (this repo focuses on **debian based images**).

> This repo follows the [ dev container feature distribution specification](https://containers.dev/implementors/features-distribution/).

**List of features:**

* [symfony-cli](src/symfony-cli/README.md): Install a Symfony-cli into your Devcontainer

## Usage

To reference a feature from this repository, add the desired features to a devcontainer.json. Each feature has a README.md that shows how to reference the feature and which options are available for that feature.

The example below installs the *symfony-cli* declared in the `./src` directory of this repository.

See the relevant feature's README for supported options.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/shyim/devcontainers-features/symfony-cli:latest": {}
    }
}
```