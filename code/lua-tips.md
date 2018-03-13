# Lua

## Some language features

### Scope

- `local` variables:  对比[lua.lua](lua.lua) 和 [lua-repl.lua](lua-repl.lua), 体会局部变量在REPL方式下执行存在的问题

- [closures](lua-repl.lua#L116)

  - **练习1**：实现 素数生成器 [lua-repl.lua](lua-repl.lua#L137)

### First class values

- function可以作为[参数](lua-repl.lua#L132)，作为[返回值](lua-repl.lua#L126)
- tables: [array](lua-repl.lua#L166), [hash](lua-repl.lua#L178)
- multiple values: [返回多个值](lua-repl.lua#L250), [赋值](lua-repl.lua#L255)

### Metaprogramming

- metatables: getmetatable( ), [setmetatable(t, mt)](lua-repl.lua#L269)
- metamethods: [__index](lua-repl.lua#L269)
  - 如果 t.a=2, 那么print(t.b), print(t.a), print(t[1]), print(t["a"])的执行结果分别是什么？体会__index元方法的作用
  - **练习2**：用__index元方法写 fibonaccia 表
- 使用 metatables 模拟 classes, 例如 [Matrix](lua-repl.lua#L275) { [new](lua-repl.lua#L277), [get](lua-repl.lua#L290)}

## Object Systems  