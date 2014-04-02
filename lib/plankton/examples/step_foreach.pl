L = [ 1, 2, 3 ]

step
  description: "A step with a foreach"
  foreach i in L
    note: "This is note %{i}"
    warning: "Caerful!"
  end
end
