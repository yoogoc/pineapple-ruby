class Parser

  def parse(code)
    lexer = Lexer.new(code)
    source_code = parse_source_code(lexer)
    lexer.next_token_is(TokenEnum::TOKEN_EOF)
    source_code
  end

  def parse_source_code(lexer)
    sc = SourceCode.new
    sc.line_num = lexer.line_num
    sc.statements = parse_statements(lexer)
    sc
  end

  def parse_print(lexer)
    lprint = Print.new
    lprint.line_num = lexer.line_num

    lexer.next_token_is(TokenEnum::TOKEN_PRINT)
    lexer.next_token_is(TokenEnum::TOKEN_LEFT_PAREN)
    lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)
    lprint.variable = parse_variable(lexer)

    lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)
    lexer.next_token_is(TokenEnum::TOKEN_RIGHT_PAREN)
    lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)

    lprint
  end

  def parse_name(lexer)
    lexer.next_token_is(TokenEnum::TOKEN_NAME)[:token]
  end

  def parse_string(lexer)
    str = ""
    case lexer.look_ahead
    when TokenEnum::TOKEN_DUOQUOTE
      lexer.next_token_is(TokenEnum::TOKEN_DUOQUOTE)
      lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)
      return str
    when TokenEnum::TOKEN_QUOTE
      lexer.next_token_is(TokenEnum::TOKEN_QUOTE)
      str = lexer.scan_before_token("\"")
      lexer.next_token_is(TokenEnum::TOKEN_QUOTE)
      lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)
      return str
    else
      raise 'parse String error'
    end
  end

  def parse_variable(lexer)
    variable = Variable.new
    variable.line_num = lexer.line_num
    lexer.next_token_is(TokenEnum::TOKEN_VAR_PREFIX)
    variable.name = parse_name(lexer)
    lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)
    variable
  end

  def parse_assignment(lexer)
    assignment = Assignment.new
    assignment.line_num = lexer.line_num
    assignment.variable = parse_variable(lexer)
    lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)
    lexer.next_token_is(TokenEnum::TOKEN_EQUAL)
    lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)
    assignment.value = parse_string(lexer)
    lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)

    assignment
  end

  def parse_statement(lexer)
    lexer.look_ahead_and_skip(TokenEnum::TOKEN_IGNORED)
    case lexer.look_ahead
    when TokenEnum::TOKEN_PRINT
      return parse_print(lexer)
    when TokenEnum::TOKEN_VAR_PREFIX
      return parse_assignment(lexer)
    else
      raise 'unknown statement'
    end
  end

  def parse_statements(lexer)
    statements = []
    while !is_source_end?(lexer.look_ahead)
      statements << parse_statement(lexer)
    end
    statements
  end

  def is_source_end?(tt)
    tt == TokenEnum::TOKEN_EOF
  end
end
