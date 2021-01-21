class Backend
  attr_accessor :parser
  def initialize
    parser = Parser.new
  end

  def execute(code)
    gv = GlobalVariables.new
    parser = Parser.new
    ast = parser.parse(code)

    resolve_ast(gv, ast)
  end

  def resolve_ast(gv, ast)
    raise 'no code to execute, please check your input!' if ast.statements.empty?
    ast.statements.each do |statement|
      statement.resolve(gv)
    end
  end

end
