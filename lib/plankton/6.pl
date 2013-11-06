x = 0

if x < 0

  y = 1

  step
    description: "A"
    note: "y = %{y}"
  end

elsif x < 1

  y = 2

  step
    description: "B"
    note: "y = %{y}"
  end

  if y+x < 1
    z = 3
  else
    z = -3
  end

  step
    description: "Z"
    note: "z = %{z}"
  end

elsif x**2 == 3

  step
    description: "What the?"
  end

else

  y = 3

  step
    description: "C"
    note: "y = %{y}"
  end

end
