// Defined through .cmake::Utils
#ifndef CMAKE_IMPORT_STD
#  include <iostream>
#  include <source_location>
#  include <span>
#endif

#ifdef CMAKE_IMPORT_STD
import std;
#endif

import dotcmake;

using namespace std;

template< auto F >
void inline Log(
  string_view const &text,
  source_location    current = source_location::current())
{
  // Specialized formatter for void functions
  using VoidFunction = void (*)();
  auto const print   = format(
    "[{}:{}][{}({})] {}\n",
    current.line(),
    current.column(),
    VoidFunction(F),
    dotcmake::GetFunctionName< F >(),
    text);
  cout << print;
}

template< auto F >
void inline Debug(
  string_view const &text,
  source_location    current = source_location::current())
{
  if constexpr (dotcmake::Compiler::DEBUG) {
    Log< F >(text, current);
  }
}

// Unspecialized Log functions
void inline Log(
  string_view const &text,
  source_location    current = source_location::current())
{
  auto const print = format(
    "[{}:{}][{}] {}\n",
    current.line(),
    current.column(),
    current.function_name(),
    text);
  cout << print;
}

void inline Debug(
  string_view const &text,
  source_location    current = source_location::current())
{
  if constexpr (dotcmake::Compiler::DEBUG) {
    Log(text, current);
  }
}

int
main(int argc, char *argv[])
{
  span< char * > args{argv, static_cast< size_t >(argc)};

  Debug< main >("Hello World");
}
