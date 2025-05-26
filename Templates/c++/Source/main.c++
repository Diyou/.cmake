// Defined through .cmake::Utils
#ifndef CMAKE_IMPORT_STD
#  include <iostream>
#  include <source_location>
#endif

#ifdef CMAKE_IMPORT_STD
import std;
#endif

import dotcmake;

using namespace std;

template< auto F >
void constexpr Log(
  string_view const &text,
  source_location    current = source_location::current())
{
  // Specialized formatter for void functions
  using VoidFunction = void (*)();
  cout << format(
    "[{}:{}][{}({})]\t{}\n",
    current.line(),
    current.column(),
    VoidFunction(F),
    dotcmake::GetFunctionName< F >(),
    text);
}

template< auto F >
void constexpr Debug(
  string_view const &text,
  source_location    current = source_location::current())
{
  if constexpr (dotcmake::Compiler::DEBUG) {
    Log< F >(text, current);
  }
}

// Unspecialized Log functions
void constexpr Log(
  string_view const &text,
  source_location    current = source_location::current())
{
  cout << format(
    "[{}:{}][{}]\t{}\n",
    current.line(),
    current.column(),
    current.function_name(),
    text);
}

void constexpr Debug(
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
  Debug< main >("Hello World");
}
