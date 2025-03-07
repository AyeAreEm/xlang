# X
- NOTE: this language is still being development. expect bugs as features<br>
X/Xlang is a statically typed compiled programming language with manual memory management

## Features
- Generics
- UTF-8 Strings
- Cross Platform
- Defer Statements
- Manual Memory Management
- Zero Initalised
- Options and Errors (as values)
- Name First Declaration
- Receiver Methods
- Compile Time Execution
- Default Function Parameters
- Allocators

```
vec2 :: struct[T] {
    x: f32,
    y: f32,
}

vec2[$T].add :: fn(^self, other: vec2[T]) void {
    self.x += other.x;
    self.y += other.y;
}

main :: fn() void {
    pos := vec2[i32]{10, 15};
    other := vec2[i32]{20, 10};

    pos.add(other);

    nums := dyn.init(i32)!; // ! == "unwrap"
    defer nums.deinit()!;

    nums.push(69)!;
    nums.push(420)!;

    for (nums) [n] {
        println("%", n);
    }

    first_num: ?i32 = nums.at(0); // don't need to specify the type, just showing the '?' option type
    if (first_num) [n] {
        println("%", n);
    } else {
        println("no number at index 0");
    }
}
```

## Why not Odin, Zig, ...?
Well, mainly because all languages miss features and I wanted a language that had certain features but there was no language that had all of them<br>
- NOTE: I'm not saying these langauges are bad for not having these features. There are reasons why they don't have said features and that's respectable

### Features Odin Doesn't Have
- Generics
- First Class Error Unions
- Receiver Methods
- Compile Time Execution

It might be good to point out that Odin has polymorphic parameters, not generics. So `Maybe(vec2(i32))` does not work. Of course there are ways around this but I want true generics

### Features Zig Doesn't Have
- Default Function Parameters
- Polymorphic Parameters
- Nameless Struct Literal Members
- Receiver Methods
- Not Being a Pain in the Ass

While Zig does have generics, if you want `fn max(x: $T, y: T) T`, this doesn't work. You'd have to pass an `anytype` which could mean that `x` and `y` are different types unless checked inside the function or do `fn max(comptime T: type, x: T, y: T) T`<br>
Also Zig is just a pain at times. Unused variables errors, Variable that isn't mutated errors, and so on. I'm sure in critical applications this would be useful but for prototyping, it sucks.
