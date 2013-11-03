##############
# Example 1
#

  argument
    x : string, "Name"
    y : number, "Mass"
    z : sample  # no description string here, just for testing
    q : object, "Container"
  end

  n = w + [1, 2] / 3.14159 + { a: 1, v : { c: "asd" } }

  step
    description : "This is a great step"
    note : "
      This is a note in which n = %{n}.
      And on another line, we say something else.
    "
    warning : "Careful!"
    warning : "Really!"
  end



