// Defined through .cmake::Utils
#ifndef CMAKE_IMPORT_STD
#  include <iostream>
#endif

#ifdef CMAKE_IMPORT_STD
import std;
#endif

import dotcmake;

using namespace std;

template< auto F > void constexpr Log(string_view const &text)
{
  // Specialized formatter for void functions
  using VoidFunction = void (*)();

  cout << format(
    "[{}({})] {}\n", VoidFunction(F), dotcmake::GetFunctionName< F >(), text);
}

template< auto F > void constexpr Debug(string_view const &text)
{
#ifndef NDEBUG
  Log< F >(text);
#endif
}

int
main(int argc, char *argv[])
{
  Debug< main >("Hello World");
}
