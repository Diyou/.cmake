# Diyou/.cmake

CMake dotfiles for common c++ projects including

- Presets for specific toolchains (native/clang/emscripten)
- Git-based Package Management
- c++20 Utils module
  - ```cmake
    include(C++Utils)
    target_link_libraries(<TARGET> dotfiles::Utils)
    ```
  - ```c++
    import dotfiles.Utils;
    ```

### Requirement

- cmake > 4.0.0
  - gcc > 15
  - clang > 19

### Usage

Add this repository as a git-submodule and use `add_subdirectory(.cmake)` before `project()` in the parent project

Include [CMakePresets.json](CMakePresets.json) from the top-level project to use supported targets:

- debug (native)
- release (native)
- debug::clang
- release::clang
- debug::emscripten
- release::emscripten
