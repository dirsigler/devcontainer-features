# Dev Container Features: Self Authoring Template

> This repo provides a starting point and example for creating your own custom [dev container Features](https://containers.dev/implementors/features/), hosted for free on GitHub Container Registry. The example in this repository follows the [dev container Feature distribution specification](https://containers.dev/implementors/features-distribution/).
>
> To provide feedback to the specification, please leave a comment [on spec issue #70](https://github.com/devcontainers/spec/issues/70). For more broad feedback regarding dev container Features, please see [spec issue #61](https://github.com/devcontainers/spec/issues/61).

## Repo and Feature Structure

Similar to the [`devcontainers/features`](https://github.com/devcontainers/features) repo, this repository has a `src` folder. Each Feature has its own sub-folder, containing at least a `devcontainer-feature.json` and an entrypoint script `install.sh`.

```
├── src
|   ├── ...
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
...
```

An [implementing tool](https://containers.dev/supporting#tools) will composite [the documented dev container properties](https://containers.dev/implementors/features/#devcontainer-feature-json-properties) from the feature's `devcontainer-feature.json` file, and execute in the `install.sh` entrypoint script in the container during build time. Implementing tools are also free to process attributes under the `customizations` property as desired.

### Options

All available options for a Feature should be declared in the `devcontainer-feature.json`. The syntax for the `options` property can be found in the [devcontainer Feature json properties reference](https://containers.dev/implementors/features/#devcontainer-feature-json-properties).

For example, the `color` feature provides an enum of three possible options (`red`, `gold`, `green`). If no option is provided in a user's `devcontainer.json`, the value is set to "red".

```jsonc
{
  // ...
  "options": {
    "favorite": {
      "type": "string",
      "enum": ["red", "gold", "green"],
      "default": "red",
      "description": "Choose your favorite color."
    }
  }
}
```

Options are exported as Feature-scoped environment variables. The option name is captialized and sanitized according to [option resolution](https://containers.dev/implementors/features/#option-resolution).

```bash
#!/bin/bash

echo "Activating feature 'color'"
echo "The provided favorite color is: ${FAVORITE}"

...
```

## Distributing Features

### Versioning

Features are individually versioned by the `version` attribute in a Feature's `devcontainer-feature.json`. Features are versioned according to the semver specification. More details can be found in [the dev container Feature specification](https://containers.dev/implementors/features/#versioning).

### Publishing

> NOTE: The Distribution spec can be [found here](https://containers.dev/implementors/features-distribution/).
>
> While any registry [implementing the OCI Distribution spec](https://github.com/opencontainers/distribution-spec) can be used, this template will leverage GHCR (GitHub Container Registry) as the backing registry.

Features are meant to be easily sharable units of dev container configuration and installation code.

This repo contains a **GitHub Action** [workflow](.github/workflows/release.yaml) that will publish each Feature to GHCR.

_Allow GitHub Actions to create and approve pull requests_ should be enabled in the repository's `Settings > Actions > General > Workflow permissions` for auto generation of `src/<feature>/README.md` per Feature (which merges any existing `src/<feature>/NOTES.md`).

By default, each Feature will be prefixed with the `<owner/<repo>` namespace. For example, the two Features in this repository can be referenced in a `devcontainer.json` with:

```
ghcr.io/devcontainers/feature-starter/color:1
ghcr.io/devcontainers/feature-starter/hello:1
```

The provided GitHub Action will also publish a third "metadata" package with just the namespace, eg: `ghcr.io/devcontainers/feature-starter`. This contains information useful for tools aiding in Feature discovery.

'`devcontainers/feature-starter`' is known as the feature collection namespace.
