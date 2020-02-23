const TokenTag = enum {
    LBRACE,
    RBRACE,
    LSQUARE,
    RSQUARE,
    COLON,
    COMMA,
    STRING,
    NUMBER,
    TRUE,
    FALSE,
    NULL,
    EMPTY_OBJ,
    EMPTY_ARR
};

pub const Token = union(TokenTag) {
    LBRACE: void,
    RBRACE: void,
    LSQUARE: void,
    RSQUARE: void,
    COLON: void,
    COMMA: void,
    STRING: []const u8,
    NUMBER: []const u8,
    TRUE: void,
    FALSE: void,
    NULL: void,
    EMPTY_OBJ: void,
    EMPTY_ARR: void
};
