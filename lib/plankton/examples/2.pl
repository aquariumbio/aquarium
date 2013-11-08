###########################################
# Example 2 : A Full Step
#

step

  description: "A Full Step"
  note: "This step has all the sub fields."
  warning: "Even a warning."
  image: "1000 mL Bottle"

  getdata
    x: number, "A number"
    y: string, "A string"
    z: string, "Choose a letter", [ "A", "B" ]
  end

end

step
  description: "You entered x = %{x}, y = %{y}, and z = %{z}."
end
