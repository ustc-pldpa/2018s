#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

typedef struct {
  int counter;
} counter_t;

static int counter_new(lua_State* L) {
  counter_t* counter = (counter_t*) lua_newuserdata(L, sizeof(counter_t));
  counter->counter = 0;
  return 1;
}

static int counter_incr(lua_State* L) {
  counter_t* counter = (counter_t*) lua_touserdata(L, 1);
  counter->counter++;
  return 0;
}

int luaopen_counter(lua_State* L) {
  lua_createtable(L, 1, 0); // local x = {}

  lua_pushstring(L, "new");
  lua_pushcfunction(L, counter_new);
  lua_settable(L, -3);

  lua_pushstring(L, "incr");
  lua_pushcfunction(L, counter_incr);
  lua_settable(L, -3);


  return 1;
}
