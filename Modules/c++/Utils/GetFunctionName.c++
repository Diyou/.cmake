module;
#ifndef CMAKE_IMPORT_STD
#  include <source_location>
#  include <string_view>
#endif
export module dotcmake:GetFunctionName;

import :Compiler;
#ifdef CMAKE_IMPORT_STD
import std;
#endif

using namespace std;
constexpr string_view empty_view;

constexpr string_view
strip_left(string_view const &view, string_view const &match)
{
  size_t pos = view.rfind(match);
  return pos == string_view::npos ? empty_view
                                  : view.substr(pos + match.size());
}

constexpr string_view
strip_right_of(string_view const &view, string_view const &match)
{
  size_t pos = view.find_first_of(match);
  return pos == string_view::npos ? empty_view : view.substr(0, pos);
}

constexpr string_view
strip(
  string_view const &view,
  string_view const &left,
  string_view const &right)
{
  return strip_right_of(strip_left(view, left), right);
}

template< auto T >
constexpr auto
GetFunctionView()
{
  constexpr string_view match_left =
    dotcmake::Compiler::GCC ? "[with auto T = " : "[T = &";
  constexpr string_view match_right = ";]>";
  constexpr string_view match_ns    = "::";

  string_view const     location = source_location::current().function_name();
  string_view const     stripped = strip(location, match_left, match_right);
  string_view const     without_namespace = strip_left(stripped, match_ns);
  return without_namespace.empty() ? stripped : without_namespace;
}

template< size_t N >
constexpr auto
to_array(string_view const &view)
{
  array< char, N + 1 > buffer{};
  view.copy(buffer.data(), N);
  return buffer;
}

namespace dotcmake {
export template< auto Function >
constexpr string_view
GetFunctionName()
{
  constexpr string_view name   = GetFunctionView< Function >();
  // Adds 0 termination
  constexpr static auto buffer = to_array< name.size() >(name);

  static_assert(
    !name.empty() && name == buffer.data(), "Function name extraction failed");

  return {buffer.data(), name.size()};
}
}
