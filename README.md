# Emacs Builder

The Emacs Builder is a Docker-based tool designed to automate the building of Emacs in Ubuntu systems, providing a comprehensive environment equipped with all necessary configurations and dependencies for advanced features such as native compilation, JSON support, and Tree Sitter integration.

## Installation

To use the Emacs Builder, ensure Docker is installed and properly configured on your system. Follow these steps to set up Emacs Builder:

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

Before building Emacs, you may want to switch to a different tag or branch to build a specific version. Navigate into the Emacs directory and check out the desired tag or branch:

```bash
cd emacs
git checkout <tag_or_branch_name>
```

For users operating on different OS versions, you may also want to edit the base image in the `FROM` stanza in the Dockerfile to match your OS version and ensure that the Docker environment is fully compatible with your system, minimizing potential issues when running Emacs.

To build Emacs, execute the following command from the root of the cloned repository:

```bash
./build
```

This script builds the Docker image if necessary, instantiates the container, and automatically starts the compilation process of Emacs. After the build process completes, the script calls `sudo make install`, which installs the build artifacts under your system's `/usr/local` directory, making Emacs binaries accessible outside the Docker environment.

### Build Modes

The build script automatically detects the appropriate build mode based on the host system:

- **X11 build** (`x`): If X11 libraries are detected (`libx11-6`), builds with full GUI support including X11, DBus, and image libraries.
- **Server build** (`server`): If X11 libraries are not found, builds for headless environments without X11, DBus, or desktop integration.

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

### Tree-sitter

The version of the tree-sitter library Emacs is built against limits which language grammars it can load. Ubuntu 24.04 ships tree-sitter 0.20.8, which cannot load grammars generated for ABI 15, such as the Rust and PHP grammars installed by Emacs 31.1. Building tree-sitter 0.25 or later from source is therefore recommended.

The build script selects the tree-sitter library as follows:

- **Source installation**: used if `~/src/tree-sitter/tree-sitter.pc` exists. Set `TREESITTER_SOURCE_DIR` to use a different directory. The library and headers are taken from the prefix recorded in `tree-sitter.pc` and mounted read-only into the container.
- **Apt package**: otherwise, Emacs is built against the `libtree-sitter-dev` package in the Docker image, and `libtree-sitter0` must be installed on the host at runtime.

To build and install tree-sitter from source:

```bash
git clone https://github.com/tree-sitter/tree-sitter.git ~/src/tree-sitter
cd ~/src/tree-sitter
git checkout v0.25.10  # 0.25 or later
make
sudo make install
sudo ldconfig
```

The library's soname includes its minor version (e.g. `libtree-sitter.so.0.25`), so Emacs keeps using the version it was built against. After upgrading tree-sitter, rebuild Emacs, and do not remove the old library until you have done so.

Language grammars do not need to be installed system-wide. Emacs 31 and later install them on demand into `~/.emacs.d/tree-sitter` when a tree-sitter mode needs one (see `treesit-auto-install-grammar`), which requires `git` and a C compiler on the host. Grammars can also be installed explicitly with `M-x treesit-install-language-grammar`.

### Required Runtime Packages

After building, ensure the following packages are installed on the system where Emacs will run.

**For X11 builds:**

```bash
sudo apt install liblcms2-2 libgccjit0
```

**For server builds:**

```bash
sudo apt install libgccjit0 libjansson4 libgnutls30 libncurses6 libxml2
```

If Emacs was built against the tree-sitter apt package rather than a source installation, also install `libtree-sitter0`.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. All contributions are greatly appreciated.

## License

Distributed under the MIT License. See LICENSE for more information.
