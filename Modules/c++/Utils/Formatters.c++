module;
#ifndef CMAKE_IMPORT_STD
#  include <format>
#endif

export module dotcmake:Formatters;
#ifdef CMAKE_IMPORT_STD
import std;
#endif

namespace std {
export
{
  // Enable generic function pointer types for format()
  using VoidFunctionPtr = void (*)();

  template<> struct formatter< VoidFunctionPtr, char >
  {
    constexpr static char        default_presentation = 'x';
    constexpr static string_view supported            = "xX";
    char                         presentation         = default_presentation;

    constexpr auto
    parse(format_parse_context &ctx)
    {
      auto iter = ctx.begin();

      if (iter != ctx.end() && *iter != '}') {
        char const chr = *iter++;
        presentation   = supported.contains(chr) ? chr : default_presentation;
      }

      // Ignore any extra characters after the format specifier
      while (iter != ctx.end() && *iter != '}') {
        ++iter;
      }

      return iter;
    }

    auto
    format(VoidFunctionPtr ptr, format_context &ctx) const
    {
      auto value = reinterpret_cast< uintptr_t >(ptr);

      if (presentation == 'X') {
        return format_to(ctx.out(), "0x{:X}", value);
      }

      return format_to(ctx.out(), "0x{:x}", value);
    }
  };
}
}
