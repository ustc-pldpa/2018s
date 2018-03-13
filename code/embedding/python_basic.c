#include <Python.h>

int main() {
  Py_Initialize();
  PyRun_SimpleString("print 'hi'");
  Py_Finalize();
}
