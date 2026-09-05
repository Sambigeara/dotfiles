/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

// Default `git blame` line:
//   <hash> [filename] (<author> <YYYY-MM-DD HH:MM:SS ±HHMM> <lineno>) <source>
// Filename is present after renames (and with -f). Author names may contain
// spaces; words starting with a digit are not part of the name so the ISO
// timestamp can be recognized without lookahead.

export default grammar({
  name: "git_blame",

  extras: $ => [],

  rules: {
    source_file: $ => repeat(choice($.line, "\n")),

    line: $ => seq(
      $.hash,
      / +/,
      optional(seq($.filename, / +/)),
      "(",
      $.author,
      / +/,
      $.timestamp,
      / +/,
      $.lineno,
      ")",
      optional(seq(" ", optional($.code))),
    ),

    hash: $ => /\^?[0-9a-f]+/,

    filename: $ => /[^(\s]\S*/,

    author: $ => /[^\d\s()][^\s()]*( [^\d\s()][^\s()]*)*/,

    timestamp: $ => /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4}/,

    lineno: $ => /\d+/,

    code: $ => /[^\n]+/,
  },
});
