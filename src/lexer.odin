package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"

TokenIdent :: struct {
    ident: string,
}
TokenIntLit :: struct {
    literal: string,
}

TokenColon :: struct {}
TokenSemiColon :: struct {}
TokenEqual :: struct {}

TokenLb :: struct {} // left bracket
TokenRb :: struct {} // right bracket
TokenLc :: struct {} // left curl
TokenRc :: struct {} // right curl

TokenComma :: struct {}

TokenPlus :: struct {}
TokenMinus :: struct {}
TokenStar :: struct {}
TokenSlash :: struct {}
TokenBackSlash :: struct {}

Token :: union {
    TokenIdent,
    TokenIntLit,

    TokenColon,
    TokenSemiColon,
    TokenEqual,

    TokenLb,
    TokenRb,
    TokenLc,
    TokenRc,

    TokenComma,

    TokenPlus,
    TokenMinus,
    TokenStar,
    TokenSlash,
    TokenBackSlash,
}

token_peek :: proc(using parser: ^Parser) -> Token {
    if len(tokens) == 0 {
        return nil
    }

    return tokens[0]
}

token_next :: proc(using parser: ^Parser) -> Token {
    if len(tokens) == 0 {
        return nil
    }
    cursors_idx += 1
    return pop_front(&tokens)
}

token_tag_equal :: proc(lhs, rhs: Token) -> bool {
    switch _ in lhs {
    case TokenPlus:
        _, ok := rhs.(TokenPlus)
        return ok
    case TokenMinus:
        _, ok := rhs.(TokenMinus)
        return ok
    case TokenStar:
        _, ok := rhs.(TokenStar)
        return ok
    case TokenSlash:
        _, ok := rhs.(TokenSlash)
        return ok
    case TokenBackSlash:
        _, ok := rhs.(TokenBackSlash)
        return ok
    case TokenIdent:
        _, ok := rhs.(TokenIdent)
        return ok
    case TokenIntLit:
        _, ok := rhs.(TokenIntLit)
        return ok
    case TokenColon:
        _, ok := rhs.(TokenColon)
        return ok
    case TokenLb:
        _, ok := rhs.(TokenLb)
        return ok
    case TokenRb:
        _, ok := rhs.(TokenRb)
        return ok
    case TokenLc:
        _, ok := rhs.(TokenLc)
        return ok
    case TokenRc:
        _, ok := rhs.(TokenRc)
        return ok
    case TokenEqual:
        _, ok := rhs.(TokenEqual)
        return ok
    case TokenSemiColon:
        _, ok := rhs.(TokenSemiColon)
        return ok
    case TokenComma:
        _, ok := rhs.(TokenComma)
        return ok
    }

    return false
}

token_expect :: proc(using parser: ^Parser, expected: Token) -> Token {
    if token := token_next(parser); token != nil {
        if !token_tag_equal(token, expected) {
            elog(parser, cursors_idx, "expected token %v, got %v", expected, token)
        }

        return token
    }

    elog(parser, cursors_idx, "expected token %v when no more tokens left", expected)
}

lexer :: proc(source: string) -> (tokens: [dynamic]Token, cursor: [dynamic][2]u32) {
    try_append :: proc(cursor: ^[dynamic][2]u32, col, row: ^u32, tokens: ^[dynamic]Token, buf: ^strings.Builder, extra_token: Token = nil) {
        if len(buf.buf) > 0 {
            append(cursor, [2]u32{row^, col^})
            string_buf := strings.to_string(buf^)
            if _, ok := strconv.parse_i64(string_buf); ok {
                append(tokens, TokenIntLit{strings.clone(string_buf)})
            } else {
                append(tokens, TokenIdent{strings.clone(string_buf)})
            }
        }

        if extra_token != nil {
            col^ += 1
            append(cursor, [2]u32{row^, col^})
            append(tokens, extra_token)
        }

        clear(&buf.buf)
    }

    buf, buf_err := strings.builder_make()
    if buf_err != nil {
        fmt.eprintfln("failed to allocate string builder")
        os.exit(1)
    }
    defer delete(buf.buf)

    row, col: u32 = 1, 1

    for ch in source {
        switch ch {
        case ' ', '\r', '\n', '\t':
            if ch == '\r' {
                continue
            }

            try_append(&cursor, &col, &row, &tokens, &buf)
            if ch == '\n' {
                row += 1
                col = 1
            } else {
                col += 1
            }
        case ':':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenColon{})
        case '(':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenLb{})
        case ')':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenRb{})
        case '{':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenLc{})
        case '}':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenRc{})
        case '=':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenEqual{})
        case ';':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenSemiColon{})
        case ',':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenComma{})
        case '+':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenPlus{})
        case '-':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenMinus{})
        case '*':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenStar{})
        case '/':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenSlash{})
        case '\\':
            try_append(&cursor, &col, &row, &tokens, &buf, TokenBackSlash{})
        case:
            append(&buf.buf, cast(u8)ch)
            col += 1
        }
    }

    return
}
