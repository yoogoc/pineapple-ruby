class Assignment
  attr_accessor :line_num, :variable, :value

  def resolve(gv)
    raise 'variable name can NOT be empty' unless variable.name

    gv.variables[variable.name.to_sym] = value
  end
end
