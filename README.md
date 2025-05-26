# dotcmake

CMake dotfiles for common c++ projects including

- Presets for specific toolchains (native/clang/emscripten)
- Git-based Package Management
- IDE integration
  - vscode
- c++20 Utils module
  - cmake:
    ```cmake
    include(C++Utils)
    target_link_libraries(<TARGET> .cmake::Utils)
    ```
  - c++:
    ```c++
    import dotcmake;
    ```

### Requirement

- cmake > 4.0.0
  - gcc > 15
  - clang > 19

### Usage

Add this repository as a git-submodule and include [CMakePresets.json](CMakePresets.json) in the top-level project to use supported targets:

- debug (native)
- release (native)
- debug::clang
- release::clang
- debug::emscripten (Requires EMSDK environment variable)
- release::emscripten (Requires EMSDK environment variable)
- debug::android (Requires ANDROID_HOME environment variable)
- release::android (Requires ANDROID_HOME environment variable)

> **_Linux NOTE:_** For vscode extensions to see environment variables export them in ~/.profile and run `source ~/.profile && /usr/bin/code` or similar

### Quick Setup

From an empty directory run:

```sh
git init && git submodule add https://github.com/Diyou/.cmake && .cmake/setup c++
```
