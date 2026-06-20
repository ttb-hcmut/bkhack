#import "/article": *
#import "./Grammar.typ": *

#let punctuation_delimiter = (
  fill: color.hsl(0deg, 40%, 60%))

#let punctuation_bracket = (
  fill: color.hsl(235deg, 40%, 40%))

#let (brak_l, brak_r) = (lexeme_0(..punctuation_bracket, "{"), lexeme_0(..punctuation_bracket, "}"))

#let (parn_l, parn_r) = (lexeme_0(..punctuation_bracket, "("), lexeme_0(..punctuation_bracket, ")"))

#let pipe = lexeme_0(..punctuation_delimiter, "∣")

#let end_of_seq = category[end of seq]

#let program = category[program]

#let command = category[command]

#let word    = category[word]

#let program_ = Prod(program, {
  Or[ #command #optional[#pipe #program] ][_Simple program_]
  Or[ #brak_l #program #end_of_seq #brak_r #optional[#pipe #program] ][_Composite program_]
  Or[ #parn_l #program #parn_r #optional[#pipe #program] ][_Subshell_]
})

#let command_ = Prod(command, {
  Or[#word #optional(command)][]
})

#let langchain = bnf(
  program_,
  command_,
	Prod(end_of_seq, {
    Or[#lexeme_0(..punctuation_delimiter, ";")][]
  }),
  Prod(category[word], {
    Or[_Omitted_][]
  }),
  Prod(category[seq connective], {
    Or(lexeme_0(..punctuation_delimiter, ";"))[_Default continuation_]
    Or(lexeme_0(..punctuation_delimiter, "&&"))[_Success continuation_]
  })
)

// vi: set nowrap:
