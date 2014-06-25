def needs path

  p = "#{path}.rb"
  s = Repo::version p

  content = Repo::contents p, s

  eval(content)

end
