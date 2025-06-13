module;
#if defined(__APPLE__) && defined(__MACH__)
#  include <TargetConditionals.h>
#  define MAC
#else
#  undef MAC
#endif

export module dotcmake:Platform;

namespace dotcmake {

export struct Platform
{
  constexpr static bool Android =
#ifdef __ANDROID__
    true;
#else
    false;
#endif

  constexpr static bool Web =
#ifdef __EMSCRIPTEN__
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

  constexpr static bool Linux =
#ifdef __linux__
    !Android && !Web;
#else
    false;
#endif

  constexpr static bool Windows =
#ifdef _WIN32
    true;
#else
    false;
#endif

  constexpr static bool macOS =
#ifdef MAC
    !IOS;
#else
    false;
#endif

  constexpr static bool MOBILE  = IOS || Android;
  constexpr static bool DESKTOP = !MOBILE;
};

}
