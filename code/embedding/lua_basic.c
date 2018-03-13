#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main () {
  lua_State* L = luaL_newstate();
  luaL_openlibs(L);

  char* cmd = "print('hi')";
  luaL_loadbuffer(L, cmd, strlen(cmd), "");
  lua_call(L, 0, 0);

  lua_close(L);
}
