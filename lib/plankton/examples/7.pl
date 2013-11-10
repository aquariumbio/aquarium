information "This protocol tests while loops"

x = 0

while x < 3

  y = 0

  while y < 3

    step
      description: "%{x},%{y}"
    end

    if x==2 && ( y==2 )

      step
        description: "Last time!"
      end

    end

    y = y + 1

  end
 
  x = x + 1

end
