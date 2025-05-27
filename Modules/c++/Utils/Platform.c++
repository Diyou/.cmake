module;
#if defined(__APPLE__) && defined(__MACH__)
#  include <TargetConditionals.h>
#  define MAC
#else
#  undef MAC
#endif
#undef ANDROID
export module dotcmake:Platform;

namespace dotcmake {
export struct Platform
{
  constexpr static bool LINUX =
#ifdef __linux__
    true;
#else
    false;
#endif

  constexpr static bool WINDOWS =
#ifdef _WIN32
    true;
#else
    false;
#endif

  constexpr static bool ANDROID =
#ifdef __ANDROID__
    true;
#else
    false;
#endif

  constexpr static bool IOS =
#if defined(MAC) && TARGET_OS_IPHONE
    true;
#else
    false;
#endif

  constexpr static bool MACOS =
#ifdef MAC
    !IOS;
#else
    false;
#endif

  constexpr static bool WASM =
#ifdef __EMSCRIPTEN__
    true;
#else
    false;
#endif
};
}
