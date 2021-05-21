# GDLisp
A Lisp-style language and REPL written using GDScript and Godot 3.3.

## Quickstart
Run the main scene. Start writing Lisp-style stuff.

## Integration into Godot games/apps
Take the `gdlisp.gd` file and drop it into your project. Create a new `gdlisp` object.

A dictionary of initialization variables can be passed as an argument (e.g. `var gdlisp = GDLISP.new({"some-identifier": myobject})`). If you want to be able to modify objects from GDLisp, these initialization variables must be some sort of reference (i.e. not a primitive). 

Call `gdlisp.parse_string('(print "hello world"))` to start execution. The `parse_string` method will return an array of return values, depending on how many root S-expressions were passed.

## Motivation
It seemed like a cool idea at the time. I also wanted to write a language that had goto statements in it. [This website was a big help for the initial interpreter.](https://norvig.com/lispy.html). I tried to avoid referencing any explicit Make a Lisp (MAL) implementations.

## TODO
- finish implementing macros
- finish implementing a way to access lists and tables
- allow for compilation to GDScript
- self host the interpreter

## Syntax

### Define a variable `(def <identifier> <value>)`
Creates a variable in the current scope and sets it to the specified value. Can shadow outer variables if used in an inner scope.

The below example will set variable `x` to value `0` in the current scope.

`(def x 0)`

### Update a variable `(= <identifier> <value>)`
Finds a variable in the current or any outer scope (in that order) and sets it to the specified value.

The below example will set variable `x` to value `10`.

`(= x 10)`

### Create a list `[ <value> ... ]` or `(list <value> ... )`
Creates and returns a list with the specified values. An empty list can be created if no values are specified.

The below example creates a list with the values `1`, `2`, and `3` and stores it in variable `x`.

`(def x [1 2 3])`

### Create a table `{ <key> <value> ... }` or `(table <key> <value> ...)`
Creates and returns a table (aka a dictionary) with the specified values. An empty table can be created if no values are specified.

The below example creates a table with the key/value pair `"hello": "world"` and stores it in variable `x`.

`(def x { "hello" "world" })`

### Create a lambda expression `(lam [<parameters>] <expression> ...)`
Creates and returns a lambda expression that takes the specified parameters and runs the specified expressions. A lambda expression does not need any parameters but must have at least 1 expression.

The below example creates a lambda expression and assigns it to the variable `double`. The lambda expression is then used to double the value `2`. The returned value will equal `4`.

```
(def double (lam [ x ] (+ x x)))

(double 2)
```

### Create a macro `(macro [<parameters>] <expression> ...)`
Not yet implemented.

### If statements `(if <condition> <expression if true> <expression if false>)`
Evaluates the condition and selects an expression to execute.

The below example checks to see if 1 is less than 2. If this is true, the `double` lambda expression will be executed, otherwise the built-in `print` function will be called.

`(if (< 1 2) (double 1) (print "this is not possible"))`

### While statements `(while <condition> <expression> ...)`
Executes the given expressions while the condition is true. There must be at least 1 expression to execute.

The below example creates and increments a variable `x` from 0 to 5.

```
(def x 0)
(while (<= x 5) (= x (+ x 1)))
```

### Do block `(do <expression> ...)`
Executes the given expressions. There must be at least 1 expression to execute. Do blocks create an implicit inner scope.

The below example creates a variable `x` and sets it equal to `0`. Then the do block will shadow the variable `x` and set it equal to `10`. Outside of the do block, the built-in function `print` will print the value of `x`, which will be `0`.

```
(def x 0)
(do (def x 10))
(print x)
```

### Label `(label <identifier>)`
Not yet implemented.
Marks the current expression as a `goto` location.

### Goto `(goto <label>)`
Not yet implemented.
Moves execution to the specified `label`. The `label` must be in the same scope or an outer scope. If the `label` has not be interpreted yet, then the interpreter will conduct a breadth-first search for the `label`.
