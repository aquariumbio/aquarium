
  argument
    i: sample
  end

  take
    x = item i
    y = 1 "Stuff" 
  end

  produce
    q = 1 "Plasmid Aliquot" from x[0]
    data
      concentration: 123
    end
    release y
  end

  release x
