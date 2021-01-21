require "./token_enum"
class Lexer

  REGEX_NAME = /^[_\d\w]+/
  KEYWORDS = {
    print: TokenEnum::TOKEN_PRINT
  }

  TOKEN_NAME_MAPPING = {
    TokenEnum::TOKEN_EOF => "EOF",
    TokenEnum::TOKEN_VAR_PREFIX => "$",
    TokenEnum::TOKEN_LEFT_PAREN => "(",
    TokenEnum::TOKEN_RIGHT_PAREN => ")",
    TokenEnum::TOKEN_EQUAL => "=",
    TokenEnum::TOKEN_QUOTE => "\"",
    TokenEnum::TOKEN_DUOQUOTE => "\"\"",
    TokenEnum::TOKEN_NAME => "Name",
    TokenEnum::TOKEN_PRINT => "print",
    TokenEnum::TOKEN_IGNORED => "Ignored"
  }

  attr_accessor :source_code
  attr_accessor :line_num
  attr_accessor :next_token
  attr_accessor :next_token_type
  attr_accessor :next_token_line_num

  def initialize(source_code)
    @source_code = source_code
    @line_num = 1
    @next_token = ''
    @next_token_type = 0
    @next_token_line_num = 0
  end

  def match_token
    tt = nil
    t = source_code[0]
    case t
    when '$'
      is_match = true
      self.skip_source_code(1)
      tt = TokenEnum::TOKEN_VAR_PREFIX
    when '('
      self.skip_source_code(1)
      tt = TokenEnum::TOKEN_LEFT_PAREN
    when ')'
      self.skip_source_code(1)
      tt = TokenEnum::TOKEN_RIGHT_PAREN
    when '='
      self.skip_source_code(1)
      tt = TokenEnum::TOKEN_EQUAL
    when '"'
      if self.next_source_code_is("\"\"")
        self.skip_source_code(2)
        tt = TokenEnum::TOKEN_DUOQUOTE
        t = "\"\""
      else
        self.skip_source_code(1)
        tt = TokenEnum::TOKEN_QUOTE
      end
    else
      if self.source_code.size.zero?
        tt = TokenEnum::TOKEN_EOF
        t = TOKEN_NAME_MAPPING[tt]
      elsif self.is_ignored?
        tt = TokenEnum::TOKEN_IGNORED
        t = "Ignored"
      elsif (self.source_code[0] == '_' || self.is_letter_of_first_sc)
        t = self.scan_name
        tt = KEYWORDS[t.to_sym]
        tt = TokenEnum::TOKEN_NAME unless tt
        self.skip_source_code(t.size)
      end
    end

    if tt
      {
        line_num: self.line_num,
        token_type: tt,
        token: t
      }
    else
      raise "unexpected symbol near #{source_code[0]}"
    end
  end

  def skip_source_code(n)
    self.source_code = self.source_code[n..-1]
  end

  def next_source_code_is(s)
    source_code[0] == s
  end

  def is_letter_of_first_sc
    c = self.source_code[0]
    (c >= 'a'  && c <= 'z') || (c >= 'A' && c <= 'Z')
  end

  def scan_name
    source_code.match(REGEX_NAME)[0]
  end

  def scan_before_token(s)
    ss = self.source_code.split(s)
    raise 'unreachable!' if ss.size < 2
    self.skip_source_code(ss[0].size)
    ss[0]
  end

  def is_white_space(c)
    case c
    when "\t", "\n", "\v", "\f", "\r", " "
      return true
    end
    return false
  end

  def is_new_line(c)
    c == "\r" || c == "\n"
  end

  def is_ignored?
    is_ignored = false

    while self.source_code.size > 0
      if self.next_source_code_is("\r\n") || self.next_source_code_is("\n\r")
        self.skip_source_code(2)
        self.line_num += 1
        is_ignored = true
      elsif is_new_line(self.source_code.chars[0])
        self.skip_source_code(1)
        self.line_num += 1
        is_ignored = true
      elsif is_white_space(self.source_code.chars[0])
        self.skip_source_code(1)
        is_ignored = true
      else
        break
      end
    end
    is_ignored
  end

  def get_next_token
    if self.next_token_line_num > 0
      self.line_num = self.next_token_line_num
      self.next_token_line_num = 0
      {
        line_num: self.line_num,
        token_type: self.next_token_type,
        token: self.next_token
      }
    else
      self.match_token
    end
  end

  def next_token_is(tt)
    token_info = get_next_token
    if tt != token_info[:token_type]
      raise "next_token_is: ti: #{token_info}, tt: #{tt}"
    end

    return token_info
  end

  def look_ahead
    if self.next_token_line_num > 0
      return self.next_token_type
    end
    now_line_num = self.line_num
    token_info = self.get_next_token
    self.line_num = now_line_num
    self.next_token_line_num = token_info[:line_num]
    self.next_token_type = token_info[:token_type]
    self.next_token = token_info[:token]
    return self.next_token_type
  end

  def look_ahead_and_skip(expected_type)
    now_line_num = self.line_num
    token_info = self.get_next_token
    if token_info[:token_type] != expected_type
      self.line_num = now_line_num
      self.next_token_line_num = token_info[:line_num]
      self.next_token_type = token_info[:token_type]
      self.next_token = token_info[:token]
    end
  end
end
