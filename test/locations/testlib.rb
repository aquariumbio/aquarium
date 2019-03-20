

require 'securerandom'

def pass
  puts "\t ... \e[0;32mpassed\e[0m"
end

def fail
  puts "\t ... \e[0;31mfailed\e[0m"
end

def wiz_spec(b, c)

  {
    fields: {
      0 => {
        name: 'a',
        capacity: -1
      },
      1 => {
        name: 'b',
        capacity: b
      },
      2 => {
        name: 'c',
        capacity: c
      }
    }
  }.to_json

end

def generic_wizard(b, c)
  wizard_name = 'W' + SecureRandom.hex(1)
  wiz = Wizard.new
  wiz.name = wizard_name
  wiz.specification = wiz_spec b, c
  wiz.description = 'A test wizard'
  wiz.save
  raise wiz.errors.full_messages.join(', ') unless wiz.errors.empty?

  wiz
end

def generic_sample(st)
  sample_name = 'S' + SecureRandom.hex(3)
  samp = Sample.new sample_type_id: st.id, name: sample_name, description: 'A test sample', project: 'Test', user_id: 1
  samp.save
  raise samp.errors.full_messages.join(', ') unless samp.errors.empty?

  samp
end

def generic_object(_st, wiz)
  object_name = 'O' + SecureRandom.hex(3)
  ot = ObjectType.new name: object_name, description: 'A test object'
  ot.handler = 'sample_container'
  ot.prefix = wiz.name
  ot.unit = 'thing'
  ot.min = 10
  ot.max = 20
  ot.release_method = 'return'
  ot.cost = 0.01
  ot.sample_type_id
  ot.save
  raise ot.errors.full_messages.join(', ') unless ot.errors.empty?

  ot
end

def make_item(ot, s)
  i = Item.make({ quantity: 1, inuse: 0 }, object_type: ot, sample: s)
  raise i.errors.full_messages.join(',') unless i.errors.empty?

  i
end
