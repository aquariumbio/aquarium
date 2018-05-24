class Class

  def checker(*args)

    # define methods to do matching
    args.each do |arg|
      m = 'is_' + arg.to_s
      self.class_eval("def #{m}; #{arg}.match(self.current) != nil; end")
    end

    # define eaters
    args.each do |arg|
      m = 'eat_a_' + arg.to_s
      err_string = '"Expected ' + arg.to_s + ' at \'#{self.current}\'"'
      self.class_eval("def #{m}; if #{arg}.match(self.current); return self.eat; else; raise #{err_string}; end; end")
    end

    # define the regexp array
    code = "def re; Regexp.union [ "
    args.each { |a| code += "#{a}," }
    code += "]; end"
    self.class_eval code

  end

  def math_function(*names)
    names.each do |name|
      code = "def #{name} x; if x.class == Fixnum || x.class == Float; Math.#{name} x; else; " + 'raise "Attempted to apply #{name} to a #{x.class}."; end; end'
      self.class_eval(code)
    end
  end

end
