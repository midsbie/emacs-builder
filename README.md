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
starts the compilation process of Emacs. After the build process completes, the script calls `sudo
make install`, which installs the build artifacts under your system's `/usr/local` directory, making
Emacs binaries accessible outside the Docker environment.

### Build Modes

The build script automatically detects the appropriate build mode based on the host system:

- **X11 build** (`x`): If X11 libraries are detected (`libx11-6`), builds with full GUI support
  including X11, DBus, and image libraries.
- **Server build** (`server`): If X11 libraries are not found, builds for headless environments
  without X11, DBus, or desktop integration.

To force a server build on a system with X11 libraries installed, use the `--server` flag:

```bash
./build --server
```

| Feature         | X11 build     | Server build     |
|-----------------|---------------|------------------|
| X11             | Yes           | No               |
| DBus            | Yes           | No               |
| GConf/GSettings | Yes           | No               |
| Image libraries | Yes           | No               |
| Sound           | Yes           | No               |
| Docker image    | Full (~1.2GB) | Minimal (~400MB) |

### Required Runtime Packages

After building, ensure the following packages are installed on the system where Emacs will run.

**For X11 builds:**

```bash
sudo apt install liblcms2-2 libgccjit0 libtree-sitter0
```

**For server builds:**

```bash
sudo apt install libgccjit0 libtree-sitter0 libjansson4 libgnutls30 libncurses6 libxml2
```

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and
create. All contributions are greatly appreciated.

## License

Distributed under the MIT License. See LICENSE for more information.
