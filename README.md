# dotcmake

CMake configuration suite for common c++ projects

## Content:

- [Presets](#usage) for specific toolchains (native/clang/emscripten/android)
- Git-based Package Management
- [IDE integration](#ide-integration)
  - [vscode](#vscode)
- [c++20 Utils module](Modules/c++)
  - cmake:
    ```cmake
    include(C++Utils)
    target_link_libraries(<TARGET> .cmake::Utils)
    ```
  - c++:
    ```c++
    import dotcmake;
    ```
  - For features review [main.c++](Templates/c++/Source/main.c++)

## Requirement:

- cmake > 4.0.0
  - gcc > 15
  - clang > 19

## Usage:

Add this repository as a git-submodule and include [CMakePresets.json](CMakePresets.json) in the top-level project to use supported targets:

| Target                                   | Description            |     Environment Variable     |
| ---------------------------------------- | ---------------------- | :--------------------------: |
| debug<br>release                         | default compiler       |                              |
| debug::clang<br>release::clang           | clang on windows/linux |                              |
| debug::emscripten<br>release::emscripten | WASM                   |            EMSDK             |
| debug::android<br>release::android       | Android                | ANDROID_HOME<br>JAVA_HOME \* |

\* Optional and should be compatible with gradle (e.g. /opt/android-studio/jbr)

## Quick Setup:

From an empty directory run:

```sh
git init && git submodule add https://github.com/Diyou/.cmake && .cmake/setup c++
```

## IDE integration:

### Vscode

- #### **_PRESETS_:**

  - For vscode extensions to see environment variables export them in ~/.profile and run `source ~/.profile && /usr/bin/code` or similar

- #### **_DEBUGGING_:**

  - .cmake can automatically copy launch configurations (launch.json) into .vscode depending on the currently configured compiler (see [Options](Options.cmake))
  - [F5] or launch the default configuration
    <br>**_NOTE:_** Don't use the cmake-tools debug icon

- #### **_Intellisense_:**
  Until cpptools fully supports c++20 modules and import std; I suggest to install vscode-clangd and disable the intellisense engine
  <br>.cmake can adjust the clangd.path automatically when cross-compiling
  <br>**_NOTE:_** Run the 'clangd: Restart language server' command after switching presets or initial build.
