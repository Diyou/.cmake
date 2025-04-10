# Diyou/.cmake

CMake dotfiles for common c++ projects including

- Presets for specific toolchains (native/clang/emscripten)
- Git-based Package Management

### Usage

Add this repository as a git-submodule and use `add_subdirectory(.cmake)` before project() in the parent project

Include [CMakePresets.json](CMakePresets.json) from the top-level project to use supported targets:

- debug (native)
- release (native)
- debug::clang
- release::clang
- debug::emscripten
- release::emscripten
