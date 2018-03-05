# PA1: RPC Library - Serialization

<!-- TOC -->
- [Overview](#overview)
- [Setup](#setup)
- [Requirements](#requirements)
- [Submitting](#submitting)
- [Part 1: Serialization](#part-1-serialization)
- [Part 2: RPC](#part-2-rpc)

<!-- /TOC -->

<!-- **Due: Tuesday, March 13, 2018 at 10:30pm** -->
## Overview

Serialization, or the conversion of data into bytestreams and back, is an
eminently useful tool in data processing and remote communication. Formats like
[JSON](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON),
[Protobuf](https://developers.google.com/protocol-buffers/), and
[pickle](https://docs.python.org/3/library/pickle.html) are commonplace in web
requests, data pipelines, databases, and so on. However, serialization is
notoriously difficult to attain in statically typed, non-reflective languages
like C++. In this assignment, we will demonstrate the power and flexibility of
Lua by implementing a small library for serializing Lua datatypes.

To put your implementation into practice, you will also write a library to do
inter-process remote procedure calls (RPC). This library will take existing
class-like interfaces and create a new implementation with an identical
interface but backed by a separate process, permitting concurrent evaluation of
Lua functions.


## Setup

Programming assignment1 (PA1) live at our GitHub website:
[ustc-fopl/2018s/PA1](https://github.com/ustc-fopl/2018s/PA1).

Clone the repository to your local machine.

``` bash
git clone https://github.com/ustc-fopl/2018s.git
```

## Requirements

You must implement the three parts of the RPC library in [`starter/rpc.lua`](starter/rpc.lua):

* `mod.serialize`
* `mod.deserialize`
* `mod.rpcify`

## Submitting

We created a personal git repository for you to submit your code. Clone your git repo by following the instructions on [our course
website](http://staff.ustc.edu.cn/%7Eyuzhang/fopl/). **This git server can only be accessed on campus network.**

When you finish your PA1, copy the file `rpc.lua` into the git repo under a
folder named `assign1`.

Then `git add assign1/rpc.lua` , `git commit`, `git push origin`.

## Part 1: Serialization

First, you are going to implement the `serialize` and `deserialize` functions.
These functions are conceptually simple: `serialize` takes as input a Lua value
and returns a string, and `deserialize` takes a string and returns a Lua value.
These two functions should fulfill the property that for all valid inputs `t`,
`deserialize(serialize(t)) == t`.

Not all Lua values can be easily serialized like closures or pointers to C
values, so your functions only need to be defined for valid Lua values. A valid
Lua value is either a number, a string, a boolean, nil, or a table containing
both keys and values that are valid Lua values. For example:

```lua
-- valid values
1
"hello"
true
nil
{foo = "bar", 1 = 2}
{1, 2, false}

-- invalid values
function() print 'hi' end
```

If your `serialize` receives an invalid Lua value or if your `deserialize`
receives an invalid serialized string, you can do absolutely whatever you want.
We won't test those cases.

It's entirely up to you how to implement your serialization&mdash;that's part
of the fun! However, it should be from scratch&mdash;don't find a JSON
implementation online and copy it into your code. To simplify your life (the
goal is not to learn how to make an amazingly robust parser), you may assume
that any string values you are asked to serialize will never contain
parentheses (neither `(` nor `)`) in the string, so you can more easily use
parentheses as delimeters in your serialized string. Don't spend too much time
to build a perfect parser.

To test your code, run `lua common/tests.lua` from the assignment directory. We
recommend adding more tests to the `serialize_tests` function to thoroughly
test your functions!

Some useful tips:

- The [`type()`](https://www.lua.org/pil/2.html) function will give you the
  type of a Lua value.

- Look at the Lua [string library (PIL)](https://www.lua.org/pil/20.html) for tools
  on generating and parsing strings. You may specifically be interested in
  `string.format` and `string.gmatch`. ( `string.gfind` was present in Lua 5.0
  but was renamed to `string.gmatch` in Lua 5.1)

- We have provided you a few helper functions in `common/util.lua`. Check them
  out!

- If don't know how to start, [Chap. 12.1 Serialization |
  PIL](https://www.lua.org/pil/12.1.html) might be helpful.

## Part 2: RPC

Now, you are going to implement a function `rpcify` that takes in a class and
returns a new class which represents the RPC-ified version of the original.
Here's a simple example:

```lua
local MyClass = {}

function MyClass.new()
    return {counter = 0}
end

function MyClass.incr(t)
    t.counter = t.counter + 1
    return t.counter
end

local normal_inst = MyClass.new()
assert(MyClass.incr(normal_inst) == 1)

local MyClassRPC = rpc.rpcify(MyClass)

local remote_inst = MyClassRPC.new()
assert(MyClassRPC.incr(remote_inst) == 1) -- same as before

local future = MyClassRPC.incr_async(remote_inst)
assert(future() == 2) -- rpcify adds asynchronous versions of each method

MyClassRPC.exit(remote_inst) -- it also adds an exit method to cleanup the process
```

Here, a "class" is essentially just a table with function values. We will
discuss a more refined notion of classes next Monday, but this is our
definition for now.

On a high level, the way an RPC-ified class should work is that invoking
`new()` forks off a new Lua process (child) which runs independently of the
original (parent). The parent invokes methods on the child by passing
serialized messages over an input pipe, and receives serialized results on an
output pipe. Within the parent process, the instance handle represents a
pointer to the child process.

More formally:

* `rpcify` takes a table `Class` with string keys mapping to function values.
  The table `class` will have a function `new(...)` that returns a table, and `t`
  will not have an `exit` key. Every function expects inputs and produces outputs
  that are serializable (or "valid" in the parlance of the previous section).

* `rpcify` returns a table `NewClass` that satisfies the following properties:

  * `NewClass` has a function `new` that forks off a child process and returns
    a local handle `inst` (a proxy) to the child.

  * For each key `k` in `Class`, `inst` contains two keys `inst.k()` and
    `inst.k_async()` that invoke the method `k` on the child process. In the
    synchronous case, `inst.k()` will block until the process returns a result.
    In the asynchronous case, `inst.k_async()` will return a function that takes
    no arguments, and when called will block until the method `k` returns.

  * `inst` contains a method `inst.exit()` that, when called, will signal the
    child process to exit and `posix.wait(...)` on the child until it dies.

  * For simplicity, your implementation may assume that a given instance will
    never have more than one call, synchronous or asynchronous, active to it from
    the parent process at any given time. For example, you do not need to support
    the parent calling two functions asynchronously and then retrieving both
    results.


To accomplish this, you'll need to understand two core operating system
utilities:

1. **fork**: invoking this function causes a new child process to fork off of
  the existing one, copying the entire contents of memory from the parent into
  the child. After the fork, both processes contain the same environment, state,
  variables, and so on--the only difference is that the `fork` function returns a
  value of 0 in the child process, and returns the child's process ID in the
  parent. For example:

    ```lua
    local posix = require("posix")

    local some_var = 1
    local pid = posix.fork()
    if pid == 0 then
        print("I am the child, and some_var is: ", some_var)
    else
        print("I am the master, my child is ", pid, " and some_var is: ", some_var)
        posix.wait(pid) -- Hangs until child process exits
    end
    ```

    Both child and parent will print the same value (1) for `some_var` because
    they both have access to the pre-fork environment. This mechanism will
    allow your RPC-ified `new` function to create a new process and share
    values like a pipe (below) between them.

2. **Pipes**: pipes allow data to pass between OS processes. They have a POSIX
  implementation, but we've abstracted that away from you into a `util.Pipe`
  class. Pipes should be treated as unidirectional--one side has the input, and
  the other side has the output. For example:

    ```lua
    local util = require("common.util")
    local posix = require("posix")
    local Pipe = util.Pipe

    local pipe = Pipe.new()
    local pid = posix.fork()

    if pid == 0 then
       -- Child process
       Pipe.write(pipe, "I am the child!")
    else
       -- Parent process
       print("Child says: " .. Pipe.read(pipe))
       posix.wait(pid)
    end
    ```

    The `write` function takes a string of arbitrary length and attempts to
    write it to the pipe, hanging until a process on the receiving end calls
    `read`. This mechanism will allow your parent process to communicate with
    your RPC-ified instance's forked process.

Additionally, you'll need one last piece of Lua magic. You will need to pass
arbitrary argument lists from the parent to the child. To access all the
arguments to a function, you can use the ellipsis syntax:

```lua
local function return_args(...)
    return {...}
end

local t = return_args(1, "foo")
print(t[1], t[2]) -- prints 1, "foo"
print(table.unpack(t))  -- prints the same thing
```

The ellipsis represents the the list of arguments given to the function. You
can explicitly turn it into a list by wrapping it with a table (`{...}`). You
can turn a table back into an argument list by using the built-in
`table.unpack` function as shown above. ( `unpack` in Lua 5.2 was moved to
`table.unpack` in Lua 5.3)

To test your code, it's the same as before: run `lua common/tests.lua`. Look
for the `rpc_tests` function.


