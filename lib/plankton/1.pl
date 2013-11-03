
  ################################### 
  # Example 1
  #

  argument
    x : string, "Name"
    y : number, "Mass"
    z : sample  # no description string here, just for testing
    q : object, "Container"
  end

  n = 1

  step
    description : "This is a great step"
    note : "
      This is a note in which n = %{n}.
      And on another line, we say something else.
    "
    warning : "Careful!"
    warning : "Really!"
  end



