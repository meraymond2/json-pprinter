const TokenTag = enum {
    LBRACE, RBRACE, LSQUARE, RSQUARE, COLON, COMMA, STRING, NUMBER, TRUE, FALSE
};

pub const Token = union(TokenTag) {
    LBRACE: void, RBRACE: void, LSQUARE: void, RSQUARE: void, COLON: void, COMMA: void, STRING: []const u8, NUMBER: f64, TRUE: void, FALSE: void
};
