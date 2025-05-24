# Diyou/.cmake

CMake dotfiles for common c++ projects including

- Presets for specific toolchains (native/clang/emscripten)
- Git-based Package Management
- IDE integration
  - vscode
- c++20 Utils module
  - cmake:
    ```cmake
    include(C++Utils)
    target_link_libraries(<TARGET> dotfiles::Utils)
    ```
  - c++:
    ```c++
    import dotfiles.Utils;
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
- debug::emscripten
- release::emscripten
