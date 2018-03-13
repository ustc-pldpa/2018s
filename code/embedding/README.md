
# Embedding Lua
## Lua 和 C之间的通信
- 两种调用视图均通过相同的C API进行通信
  - C调用Lua时称C代码为application code
  - Lua调用C时称C代码为library code
- Lua和C之间交换值面临的主要问题
  - 类型系统不匹配：动态 vs. 静态
  - 内存管理不匹配：自动 vs. 手动 
- 通过栈进行Lua和C之间的数据交换
  - 栈是Lua状态的一部分
  - 提供不同的函数来将不同类型的值压入栈
  - 栈不是全局结构，每个函数有自己私有的局部栈。当Lua调用C函数时，第一个参数在局部栈的index 始终为1。
- 利用 Lua 来配置程序
## Examples
- C调用Lua
  - [lua_basic.c](embedding/lua_basic.c)  
  - [lua_add.c](embedding/lua_add.c) 
- Lua调用C
  - [counter_test.lua](embedding/counter_test.lua)调用[counter.c](embedding/counter.c)
## C API
- 支持不同类型值的压栈 API
```
void lua_pushnil (lua_State *L);
void lua_pushboolean(lua_State *L, int bool);
void lua_pushnumber(lua_State *L, lua_Number n);
void lua_pushinteger(lua_State *L, lua_Integer n);
void lua_pushlstring(lua_State *L, const char *s, size_t len);
void lua_pushstring(lua_State *L, const char *s);

typedef int (*lua_CFunction) (lua_State *L);
void lua_pushcfunction(lua_State *L, lua_CFunction l_sin);
```
- 栈的空间大小
  - 最小的容纳空间`LUA_MINSTACK` (`lua.h`)
  - 检查栈空间是否足够，不够则增长
```
int lua_checkstack (lua_State *L, int sz);
void luaL_checkstack (lua_State *L, int sz, const char *msg);
```

- 其他栈操作
```
int lua_gettop(lua_State *L);
void lua_settop(lua_State *L, int index);
void lua_pushvalue (lua_State *L, int index);
void lua_rotate(lua_State *L, int index, int n);
void lua_remove(lua_State *L, int index);
void lua_insert(lua_State *L, int index);
void lua_replace(lua_State *L, int index);
void lua_copy(lua_State *L, int fromidx, int toidx);
```
- 内存分配
  - 利用缺省的`malloc-realloc-free`创建新状态
    - 不同的Lua状态彼此独立，不共享任何数据
    - Lua状态之间不能直接通信

```
lua_State *luaL_newstate()
```
  - 自行控制分配: 指定分配函数`f`、用户数据`ud` 两个参数, 按这种方式创建的状态通过调用`f`来分配和释放；`ptr`是要再分配或释放的块地址，`osize`是以前分配的块大小，`nsize`是需要分配的块大小。

```
typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);
lua_State *lua_newstate (lua_Alloc f, void *ud);
```

  - 获取和设置指定状态 L 的内存分配器和用户数据

```
lua_Alloc lua_getallocf (lua_State *L, void **ud);
void lua_setallocf (lua_State *L, lua_Alloc f, void *ud);
```
- configuration
  - 调用 `luaL_loadfile(L, fname)`从文件中加载配置
  - 调用 [`luaL_loadbuffer(L, str, strlen, "")`](embedding/lua_add.c#L11) 从字符串缓冲区中加载配置
  - 在C 中调用[lua_getglobal(L, "add")](embedding/lua_add.c#L15) 获取配置表中的变量 add
- 调用
  - 从Lua中调用的C函数可以通过 `lua_pcall` 和`lua_call` 回调Lua
- 关闭状态 `lua_close(L)`
   
## 在Lua中调用C
**示例**：[counter.c](embedding/counter.c)定义了 C模块(module) counter, [counter_test.lua](embedding/counter_test.lua) 调用索定义的counter模块

- 栈
### 定义 C Modules
- 每个C module 有唯一的public (extern)函数，其余的都是private (static).
  在 [counter.c](embedding/counter.c) 中, 
  - [luaopen_counter()](embedding/counter.c#L23) 定义了名为 counter的module的public函数
  - 该module有两个私有函数 [counter_new()](embedding/counter.c#L11)、 [counter_incr()](embedding/counter.c#L17) 
- 将[counter.c](embedding/counter.c)编译连接得到动态库 counter.so (Linux) 或者counter.dll (Windows)

### 在Lua中调用C库
- 利用[require](embedding/counter_test.lua)加载C库 `counter`
- 调用C库中的 [`new`](embedding/counter_test.lua#L2)和 [`incr`](embedding/counter_test.lua#L3)
