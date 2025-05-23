module;

export module dotfiles.Utils:Compiler;

namespace cmake {
export struct Compiler
{
#if defined(__GNUC__) && !defined(__clang__)
  constexpr static bool GCC   = true;
  constexpr static bool CLANG = false;
#else
  constexpr static bool GCC   = false;
  constexpr static bool CLANG = true;
#endif

#if defined(_MSC_VER)
  constexpr static bool MSVC = true;
#else
  constexpr static bool MSVC = false;
#endif
#if defined(__EMSCRIPTEN__)
  constexpr static bool EMSCRIPTEN = true;
#else
  constexpr static bool EMSCRIPTEN = false;
#endif
};
}
