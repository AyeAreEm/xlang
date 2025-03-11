package main

import "core:fmt"
import "core:os"
import "core:strings"

args_next :: proc(args: ^[]string, arg: string) -> string {
    if len(args) == 0 {
        elog("expected another argument")
    }

    arg := args[0]
    args^ = args[1:]
    return arg
}

debug :: proc(format: string, args: ..any) {
    fmt.eprint("[DEBUG]: ")
    fmt.eprintfln(format, ..args)
}

usage :: proc() {
    fmt.eprintln("USAGE: ")
    fmt.eprintln("    build [filename.cur] | build executable")
}

current_elog :: proc(format: string, args: ..any) -> ! {
    fmt.eprintf("\x1b[91;1merror\x1b[0m: ")
    fmt.eprintfln(format, ..args)
    usage()

    os.exit(1)
}

elog :: proc{current_elog, parse_elog, analyse_elog}

build :: proc(filename: string) {
    content_bytes, content_bytes_ok := os.read_entire_file(filename)
    if !content_bytes_ok {
        fmt.eprintfln("failed to read %v", filename)
        os.exit(1)
    }

    content := transmute(string)content_bytes
    tokens, cursors := lexer(content)
    assert(len(tokens) == len(cursors), "expected the length of tokens and length of cursors to be the same")

    parser := Parser {
        tokens = tokens, // NOTE: does this do a copy? surely not
        in_func_decl_args = false,
        in_func_call_args = false,

        filename = filename,
        cursors = cursors,
        cursors_idx = -1,
    }

    ast := [dynamic]Stmnt{}
    for stmnt := parse(&parser); stmnt != nil; stmnt = parse(&parser) {
        append(&ast, stmnt)
    }

    symtab := SymTab{
        scopes = [dynamic]map[string]Stmnt{},
        curr_scope = 0,
    }
    append(&symtab.scopes, map[string]Stmnt{})

    env := Analyser{
        ast = ast,
        symtab = symtab,

        filename = filename,
        cursors = cursors,
        cursors_idx = -1
    }
    
    analyse(&env)
    debug("AST")
    for stmnt in env.ast {
        stmnt_print(stmnt, 1)
    }
}

main :: proc() {
    args := os.args
    if len(args) == 1 {
        usage()
        os.exit(1)
    }

    arg0 := args_next(&args, "")
    command := args_next(&args, arg0)

    if strings.compare(command, "build") == 0 {
        filename := args_next(&args, command)
        build(filename)
    } else {
        elog("unexpected command %v", command)
    }
}
