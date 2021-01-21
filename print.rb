class Print
  attr_accessor :line_num, :variable

  def resolve(gv)
    raise 'variable name can NOT be empty' unless variable.name
    str = gv.variables[variable.name.to_sym]
    raise "variable '#{variable.name}'not found" unless str
    puts str
  end
end
