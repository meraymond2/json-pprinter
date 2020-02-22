# json-printer
A toy JSON pretty-printer written in Zig.

## Goals
1. Speed — no more than 3x slower than `jq`
2. Basic pretty-printing — no clever decisions about whether or not object can be inlined, everything starts on a new line
3. Read from stdin, print to stdout

Not sure about error handling, I’m not sure if I want to parse the JSON, or just print it. E.g., should I catch double colons? Some mistakes are easy to catch, because I just have to look at the adjacent tokens, but some are more complicated, like matching brackets.

## TODO
1. Handle literal name tokens, true, false and null.
2. Handle numeric literals.
3. Handle arrays.
4. Handle string escapes?
5. Fix allocation - use arena allocator
6. String-tokens can possibly be pointers to input string, since I'll keep that in memory anyway. Unless I stream the input.
7. Fix output, can I speed up/stream the printing somehow?

(Json spec)[http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf]
