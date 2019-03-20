

require_relative 'testlib'

class Test

  def cleanup
    puts 'Cleaning up'
    @i.delete if @i
    if @wiz
      @wiz.locators.each(&:destroy)
      @wiz.destroy
    end
    @samp.destroy if @samp
    @ot.destroy if @ot
  end

  def initialize

    @wiz = generic_wizard 16, 81
    puts '    created ' + @wiz.name

    st = SampleType.find_by_name('Primer')
    @samp = generic_sample st
    puts '    created ' + @samp.name

    @ot = generic_object st, @wiz
    puts '    created ' + @ot.name

    puts 'Making initial item off grid'
    i = Item.new quantity: 1, inuse: 0, object_type_id: @ot.id, sample_id: @samp.id
    i.location = 'Nether'
    i.save
    raise i.errors.full_messages.join(',') unless i.errors.empty?
    raise "incorrect location #{i.location} for #{i.inspect}" unless i.location == 'Nether'

    puts '      new location = ' + i.location
    puts "      locator = #{i.locator_id}"

    locstr = "#{@wiz.name}.0.0.0"
    puts 'Moving item'
    i.location = locstr
    puts i.inspect.to_s

    raise "incorrect location #{i.location} for #{i.inspect}" unless i.location == locstr

    puts '      new location = ' + i.location
    puts "      locator = #{i.locator_id}"

    cleanup
    pass
  rescue Exception => e
    puts "\n"
    puts e.to_s
    puts e.backtrace.join("\n")
    cleanup
    raise

  end

end

Test.new
