
  ################################### 
  # Example 1 : A Plankton Protocol 
  #

  argument
    x: string, "Name"
    y: number, "Mass"
    z: sample  
    q: object, "Container"
  end

  m = y
  n = m+y

  step
    description: "The first step"
    note: "
      In this step, n = %{n}.
    "
    warning: "Careful!"
    warning: "Really!"
  end

  n = n+1

  step
    description: "The second step"
    note: "Now n = %{n}."
  end
