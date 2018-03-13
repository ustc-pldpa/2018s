#include <Python.h>

int main() {
  Py_Initialize();
  PyRun_SimpleString("def add(x, y): return x + y");
  PyObject* globals = PyImport_AddModule("__main__");
  PyObject* add = PyObject_GetAttrString(globals, "add");

  PyObject* arglist = Py_BuildValue("(i,i)", 5, 6);
  PyObject* result = PyEval_CallObject(add, arglist);
  Py_DECREF(arglist);

  long n = PyInt_AsLong(result);
  Py_DECREF(result);
  printf("%lu\n", n);

  Py_Finalize();
}
