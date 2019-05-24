# frozen_string_literal: true

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

    puts 'Making item'
    i = make_item @ot, @samp
    raise "incorrect location #{i.location} for #{i.inspect}" unless i.location == "#{@wiz.name}.0.0.0"

    puts '      new location = ' + i.location

    puts 'Moving item'
    i.location = "#{@wiz.name}.0.1.4"
    raise "incorrect location #{i.location} for #{i.inspect}" unless i.location == "#{@wiz.name}.0.1.4"

    puts '      new location = ' + i.location
    puts "      locator = #{i.locator_id}"

    puts 'Moving item off grid'
    loc = i.locator
    i.location = 'Nether'
    loc.reload
    raise "incorrect location #{i.location} for #{i.inspect}" unless i.location == 'Nether'
    raise "locator not updated for #{i.inspect} and #{loc.inspect}" unless i.locator_id.nil? && loc.item_id.nil?

    puts '      new location = ' + i.location
    puts "      locator = #{i.locator_id}"

    puts 'Restoring item'
    i.store
    raise "incorrect location #{i.location} for #{i.inspect}" unless i.location == "#{@wiz.name}.0.0.0"

    puts '      new location = ' + i.location
    puts "      locator = #{i.locator_id}"

    puts 'Moving item off grid'
    loc = i.locator
    i.location = 'Nether'
    loc.reload
    raise "incorrect location #{i.location} for #{i.inspect}" unless i.location == 'Nether'
    raise "locator not updated for #{i.inspect} and #{loc.inspect}" unless i.locator_id.nil? && loc.item_id.nil?

    puts '      new location = ' + i.location

    puts 'Restoriong item via location='
    i.location = "#{@wiz.name}.0.0.7"
    raise "incorrect location #{i.location} for #{i.inspect}" unless i.location == "#{@wiz.name}.0.0.7"

    puts '      new location = ' + i.location
    puts "      locator = #{i.locator_id}"

    cleanup
    pass
  rescue StandardError => e
    puts "\n"
    puts e.to_s
    puts e.backtrace[0, 3].join("\n")
    cleanup
    raise

  end

end

Test.new
