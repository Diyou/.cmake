module;

export module dotcmake:Compiler;

namespace dotcmake {

export struct Compiler
{
  /// @brief Has Debug Symbols
  constexpr static bool DEBUG =
#ifndef NDEBUG
    true;
#else
    false;
#endif

  /// @brief Compiler is a Clang variant
  constexpr static bool CLANG =
#if defined(__clang__)
    true;
#else
    false;
#endif

  /// @brief Compiler is GCC
  constexpr static bool GCC =
#if defined(__GNUC__)
    !CLANG;
#else
    false;
#endif

  /// @brief Compiler is MSVC
  constexpr static bool MSVC =
#if defined(_MSC_VER)
    !CLANG;
#else
    false;
#endif

  /// @brief Compiler is emscripten EMCC
  constexpr static bool EMCC =
#if defined(__EMSCRIPTEN__)
    true;
#else
    false;
#endif
};

}
