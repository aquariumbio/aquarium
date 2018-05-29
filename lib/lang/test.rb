# frozen_string_literal: true

def separate_string(s)
  t = (s.gsub /(%\{[^\}]*\})/, '__PLUS__\1__PLUS__').split('__PLUS__')
  r = '""'
  t.each do |p|
    r += '+'
    r = if /(%\{[^\}]*\})/.match p
          r + p + '.to_s'
        else
          r + '"' + p + '"'
        end
  end
  r
end

s = 'A step with a foreach and with L=%{L}'

scope = { x: 1, y: 2, L: [1, 2, 3] }

q = separate_string s.to_s

puts q
e = eval(q % scope)

puts e
