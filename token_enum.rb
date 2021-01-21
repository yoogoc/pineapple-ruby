class TokenEnum
  include Ruby::Enum

  define :TOKEN_EOF, 0                # end-of-file
  define :TOKEN_VAR_PREFIX, 1         # $
  define :TOKEN_LEFT_PAREN, 2         # (
  define :TOKEN_RIGHT_PAREN, 3        # )
  define :TOKEN_EQUAL, 4              # =
  define :TOKEN_QUOTE, 5              # "
  define :TOKEN_DUOQUOTE, 6           # ""
  define :TOKEN_NAME, 7               # Name ::= [_A-Za-z][_0-9A-Za-z]*
  define :TOKEN_PRINT, 8              # print
  define :TOKEN_IGNORED, 9            # ignored
end
