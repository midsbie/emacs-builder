# Emacs Builder

The Emacs Builder is a Docker-based tool designed to automate the building of Emacs in Ubuntu
systems, providing a comprehensive environment equipped with all necessary configurations and
dependencies for advanced features such as native compilation, JSON support, and Tree Sitter
integration.

## Installation

To use the Emacs Builder, ensure Docker is installed and properly configured on your system. Follow
these steps to set up Emacs Builder:

1. Clone this repository to your local machine:

    ```bash
    git clone git@github.com:midsbie/emacs-builder.git
    cd emacs-builder
    ```

2. Initialize the submodule

    ```bash
    git submodule update --init
    ```

## Usage

Before building Emacs, you may want to switch to a different tag or branch to build a specific
version. Navigate into the Emacs directory and check out the desired tag or branch:

```bash
cd emacs
git checkout <tag_or_branch_name>
```

For users operating on different OS versions, you may also want to edit the base image in the `FROM`
stanza in the Dockerfile to match your OS version and ensure that the Docker environment is fully
compatible with your system, minimizing potential issues when running Emacs.

To build Emacs, execute the following command from the root of the cloned repository:

```bash
./build
```

This script builds the Docker image if necessary, instantiates the container, and automatically
starts the compilation process of Emacs. The build artifacts will be placed under your system's
`/usr/local` directory, making Emacs binaries accessible outside the Docker environment.

### Target Environment

The build script allows you to specify the target environment for Emacs. You can export the
`TARGET_ENV` variable with values `x` or `term` to force the build to target a specific environment:

- `x` for GUI environment
- `term` for terminal environment

If `TARGET_ENV` is not set, the script attempts to determine the correct environment based on the
presence of a GUI.

```bash
export TARGET_ENV=x    # For GUI environment
export TARGET_ENV=term # For terminal environment
```

Then run the build script:

```bash
./build
```

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and
create. All contributions are greatly appreciated.

## License

Distributed under the MIT License. See LICENSE for more information.
