Operation Table Inputs
---

Create a table proc that validates numbered inputs between [1,10] initialized with a random default value between [0,20].

```ruby
    create_table = Proc.new { |ops|
        ops.start_table
        .custom_input(:new_input, heading: "Tech input", type: "number") { |op| op.temporary[:new_input] || rand(20) }
        .validate(:new_input) { |op, val| val.between?(1,10) }
        .validation_message(:new_input) { |op, key, value|
          "The value #{value} you entered for for operation #{op.id} for key #{key} is incorrect. It must be between [1,10]!"
        }
        .end_table
     }
            
    show_with_input_table(operations.running, create_table, num_times=5) do
      title "Fill in Input Table"
      
      # warnings for invalid inputs will show up here
      
      note "Go through each row and fill in."
      warning "Be sure to fill in the table correctly!"
      
      # table will be displayed below
    end
```

#### Temporary values

Inputted values are saved to each operations temporary hash by the key indicated in `.custom_input`

#### Default Values

Default values for each row in the column are specified by the block following `.custom_input` method

#### Validation
The show block will repeat up to `num_times` until all inputs are valid. 

#### Validation Messages
Warning messages for invalid inputs will be displayed at the top of show block. 
These messages can be customized via the `.validation_message` method.

### Complex Example

Virtual operations can be used as well. 
In the following example, a virtual operation is created for each plate. 
The Virtual Operation list is used to create an input table. 

This is useful for things like checking concentrations, volumes, etc. of many tubes

```ruby
# Create virtual operations
    plates.each_with_index do |p, i|
      insert_operation i, VirtualOperation.new
    end
    
    myops = operations.select { |op| op.virtual? }
    myops.zip(plates).each { |op| op.temporary[:plate] = p }
   
# Setup table
    create_table = Proc.new {|ops|
          ops.start_table
              .custom_column(heading: "Plate id") {|op| x = {content: op.temporary[:plate].id, check: true} }
              .custom_input(CONFLUENCY, heading: "Confluency (%)", type: "number") {|op| op.temporary[CONFLUENCY] || op.temporary[:plate].confluency }
              .validate(CONFLUENCY) {|op, val| valid_confluency?(val)}
              .validation_message(CONFLUENCY) {|op, k, v|
                  "Confluency for plate #{op.temporary[:plate]} is invalid. \
                    Should be between 0 and #{MAX_CONFLUENCY}"}
              .custom_input(:buffer_color, heading: color_table_matrix, type: "string") {|op| op.temporary[:buffer_color] || 'red'}
              .custom_input(:status, heading: "status", type: "string") { |op| op.temporary[:status] || 'OK' }
              .custom_column(heading: "Image Name") {|op| op.temporary[:image_name]}
              .custom_column(heading: "Image Uploaded?") {|op|
                    upload_file = op.temporary[:upload]
                    val = {content: "missing", check: true}
                    val.merge!({content: image_tag_from_upload(upload_file)}) if upload_file
                    val
                  }
              .end_table
        }

# Show block for input table
    show_with_input_table(myops, create_table) do
       title "Review"
        note "The full results of your selections are displayed below"
        check "Make any necessary edits."
        note "Note that missing or contaminated plates will not be displayed correctly."
    end
```