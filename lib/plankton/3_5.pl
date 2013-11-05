
  produce
    y = 1 "1000 mL Bottle" 
  end

  step 
    description: "Produce Completed"
    note: "y = %{y}"
  end

  produce
    z = 1 "Petri Dish"
    data
      cells: "lots"
      bubbles: "not much"
    end
    release y
  end
