#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main () {
  lua_State* L = luaL_newstate();
  luaL_openlibs(L);

  char* cmd = "add = function(x, y) return x + y end";
  luaL_loadbuffer(L, cmd, strlen(cmd), "");
  lua_call(L, 0, 0);

  lua_getglobal(L, "add");

  lua_pushnumber(L, 1);
  lua_pushnumber(L, 5);
  lua_call(L, 2, 1);

  printf("%.f\n", lua_tonumber(L, 1));

  lua_close(L);
}
