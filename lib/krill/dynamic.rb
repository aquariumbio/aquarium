class C

  def initialize

    code = "def protocol; puts 'it worked'; end"

    eval(code)

  end

end

c = C.new

c.protocol
