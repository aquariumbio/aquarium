class Class

  def checker(*args)

    # define methods to do matching
    args.each do |arg|
      m = 'is_' + arg.to_s
      self.class_eval("def #{m}; #{arg.to_s}.match(self.current) != nil; end")
    end

    # define eaters
    args.each do |arg|
      m = 'eat_a_' + arg.to_s
      err_string = '"Expected ' + arg.to_s + ' at \'#{self.current}\'"'
      self.class_eval("def #{m}; if #{arg.to_s}.match(self.current); return self.eat; else; raise #{err_string}; end; end")
    end

    # define the regexp array
    code = "def re; Regexp.union [ "
    args.each { |a| code += "#{a}," }
    code += "]; end"
    self.class_eval code

  end

end
