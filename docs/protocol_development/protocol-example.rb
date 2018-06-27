# Author: Ayesha Saleem
# November 5, 2016
# Revision: Justin Vrana, 2017-07-21 (corrected index error, refactored collection removal proceedure, added batch replacement, added plasimd stock dilution)

needs 'Cloning Libs/Special Days'
needs 'Standard Libs/Debug'

class Protocol

  include SpecialDays
  include Debug

  # io
  CELLS = 'Comp Cells'.freeze
  INPUT = 'Plasmid'.freeze
  OUTPUT = 'Transformed E Coli'.freeze

  # debug
  DEBUG_WITH_REPLACEMENT = false

  # specs
  RESUSPENSION_VOL = 900 # how much to resuspend transformed cells in

  def main

    # Detract comp cells from batches, store how many of each type of comp cell there are, and figure out how many Amp vs Kan plates will be needed

    # Determine replacements of e coli comp cell batch
    operations.running.each do |op|
      comp_cells = op.input(CELLS)
      # If current batch is empty
      next unless comp_cells.collection.empty? || (debug && DEBUG_WITH_REPLACEMENT)
      old_batch = comp_cells.collection

      # Find replacement batches
      all_batches = Collection.where(object_type_id: comp_cells.object_type.id).keep_if { |b| !b.empty? }
      batches_of_cells = all_batches.select { |b| b.include?(comp_cells.sample && !b.deleted?) }.sort(&:num_samples)
      batches_of_cells.reject! { |b| b == old_batch } # debug specific rejection to force replacement

      # Error if not enough
      if batches_of_cells.empty?
        op.error :not_enough_comp_cells, "There were not enough comp cells of #{comp_cells.sample.name} to complete the operation."
      else
        # Set input to new batch
        comp_cells.set collection: batches_of_cells.last

        # Display warning
        op.associate :comp_cell_batch_replaced, "There were not enough comp cells for this operation. Replaced batch #{old_batch.id} with batch #{comp_cells.collection.id}"
      end
    end

    # Detract from running batches
    operations.running.each do |op|
        comp_cells = op.input(CELLS)
        comp_cells.collection.remove_one comp_cells.sample
    end

    # Exit early if there are no more running operations
    if operations.empty?
      show do
        title 'All operations have errored'

        note 'All operations have errored out.'
      end
      return {}
    end

    # Make
    operations.running.retrieve(only: ['Plasmid']).make

    # Prepare electroporator
    cell_id_list = operations.running.collect { |op| op.output(OUTPUT).item.id.to_s }.join(',')
    tube_count = operations.running.length
    show do
      title 'Prepare bench'
      note 'If the electroporator is off (no numbers displayed), turn it on using the ON/STDBY button.'
      note 'Set the voltage to 1250V by clicking the up and down buttons.'
      note ' Click the time constant button to show 0.0.'
      image 'Actions/Transformation/initialize_electroporator.jpg'

      check "Retrieve and label #{tube_count} 1.5 mL tubes with the following ids: #{cell_id_list} "
      check 'Set your 3 pipettors to be 2 L, 42 L, and 300 L.'
      check 'Prepare 10 L, 100 L, and 1000 L pipette tips.'
      check 'Grab a Bench SOC liquid aliquot (sterile) and loosen the cap.'
    end

    # Measure plasmid stock concentrations 
    ops_for_dilution = operations.running.select { |op| op.input(INPUT).object_type.name == 'Plasmid Stock' }
    ops_for_measurement = ops_for_dilution.select { |op| op.input(INPUT).item.get(:concentration).to_f == 0.0 }
    if ops_for_measurement.any?
      conc_table = proc do |ops|
        ops.start_table
           .input_item(INPUT)
           .custom_input(:concentration, heading: 'Concentration (ng/ul)', type: 'number') do |op|
          x = op.temporary[:concentration] || -1
          x = rand(10..100) if debug
          x
        end
           .validate(:concentration) { |_op, v| v.between?(0, 10_000) }
           .validation_message(:concentration) { |_op, _k, _v| 'Concentration must be non-zero!' }
           .end_table.all
      end

      show_with_input_table(ops_for_measurement, conc_table) do
        title 'Measure concentrations'
        note 'The concentrations of some plasmid stocks are unknown.'
        check 'Go to the nanodrop and measure the concentrations for the following items.'
        check 'Write the concentration on the side of each tube'
      end

      ops_for_measurement.each do |op|
        op.input(INPUT).item.associate :concentration, op.temporary[:concentration]
      end
    end

    # Dilute plasmid stocks
    if ops_for_dilution.any?
      show do
        title 'Prepare plasmid stocks'

        ops_for_dilution.each do |op|
          i = produce new_sample op.input(INPUT).sample.name, of: op.input(INPUT).sample_type, as: '1 ng/µL Plasmid Stock'

          op.temporary[:old_stock] = op.input(INPUT).item
          op.input(INPUT).item.associate :from, op.temporary[:old_stock].id
          vol = 0.5
          c = op.temporary[:old_stock].get(:concentration).to_f
          op.temporary[:water_vol] = (vol * c).round(1)
          op.temporary[:vol] = vol
          op.input(INPUT).set item: i
          op.associate :plasmid_stock_diluted, "Plasmid stock #{op.temporary[:old_stock].id} was diluted and a 1 ng/ul Plasmid Stock was created: #{op.input(INPUT).item.id}"
        end

        check "Grab <b>#{ops_for_dilution.size}</b> 1.5 mL tubes and place in rack"
        note 'According to the table below:'
        check 'Label all tubes with the corresponding Tube id'
        check 'Pipette MG H20'
        check 'Pipette DNA'
        table ops_for_dilution.start_table
                              .input_item(INPUT, heading: 'Tube id', checkable: true)
                              .custom_column(heading: 'MG H20', checkable: true) { |op| "#{op.temporary[:water_vol]} ul" }
                              .custom_column(heading: 'Plasmid Stock (ul)', checkable: true) { |op| "#{op.temporary[:vol]} ul of #{op.temporary[:old_stock].id}" }
                              .end_table
      end

      show do
        title 'Set aside old plasmid stocks'

        note 'The following plasmid stocks will no longer be needed for this protocol.'
        check 'Set aside the old plasmid stocks:'
        ops_for_dilution.each do |op|
          check op.temporary[:old_stock].to_s
        end
      end
    end

    # Get comp cells and cuvettes
    show do
      title 'Get cold items'
      note 'Retrieve a styrofoam ice block and an aluminum tube rack. Put the aluminum tube rack on top of the ice block.'
      image 'arrange_cold_block'
      check "Retrieve #{operations.length} cuvettes and put inside the styrofoam touching ice block."
      note 'Retrieve the following electrocompetent aliquots from the M80 and place them on an aluminum tube rack: '
      operations.group_by { |op| op.input(CELLS).item }.each do |batch, grouped_ops|
        check "#{grouped_ops.size} aliquot(s) of #{grouped_ops.first.input(CELLS).sample.name} from batch #{batch.id}"
      end
      image 'Actions/Transformation/handle_electrocompetent_cells.jpg'
    end

    # Label comp cells
    show do
      title 'Label aliquots'
      aliquots_labeled = 0
      operations.group_by { |op| op.input(CELLS).item }.each do |_batch, grouped_ops|
        if grouped_ops.size == 1
          check "Label the electrocompetent aliquot of #{grouped_ops.first.input(CELLS).sample.name} as #{aliquots_labeled + 1}."
        else
          check "Label each electrocompetent aliquot of #{grouped_ops.first.input(CELLS).sample.name} from #{aliquots_labeled + 1}-#{grouped_ops.size + aliquots_labeled}."
        end
        aliquots_labeled += grouped_ops.size
      end
      note 'If still frozen, wait till the cells have thawed to a slushy consistency.'
      warning 'Transformation efficiency depends on keeping electrocompetent cells ice-cold until electroporation.'
      warning 'Do not wait too long'
      image 'Actions/Transformation/thawed_electrocompotent_cells.jpg'
    end

    index = 0

    # Display table to tech
    show do
      title 'Add plasmid to electrocompetent aliquot, electroporate and rescue '
      note 'Repeat for each row in the table:'
      check 'Pipette 2 uL plasmid/gibson result into labeled electrocompetent aliquot, swirl the tip to mix and place back on the aluminum rack after mixing.'
      check 'Transfer 42 uL of e-comp cells to electrocuvette with P100'
      check "Slide into electroporator, press PULSE button twice, and QUICKLY add #{RESUSPENSION_VOL} uL of SOC"
      check "pipette cells up and down 3 times, then transfer #{RESUSPENSION_VOL} uL to appropriate 1.5 mL tube with P1000"
      table operations.running.start_table
                      .input_item('Plasmid')
                      .custom_column(heading: 'Electrocompetent Aliquot') { index += 1 }
                      .output_item('Transformed E Coli', checkable: true)
                      .end_table
    end

    # Incubate transformants
    show do
      title 'Incubate transformants'
      check 'Grab a glass flask'
      check 'Place E. coli transformants inside flask laying sideways and place flask into shaking 37 C incubator.'
      # Open google timer in new window
      note "<a href=\'https://www.google.com/search?q=30%20minute%20timer\' target=\'_blank\'>Use a 30 minute Google timer</a> to set a reminder to retrieve the transformants, at which point you will start the \'Plate Transformed Cells\' protocol."
      image 'Actions/Transformation/37_c_shaker_incubator.jpg'
      note 'While the transformants incubate, finish this protocol by completing the remaining tasks.'
    end

    # plate pre heating
    show do
      title 'Pre-heat plates'
      note 'Retrieve the following plates, and place into still 37C incubator.'
      grouped_by_marker = operations.running.group_by do |op|
        op.input(INPUT).sample.properties['Bacterial Marker'].upcase
      end
      grouped_by_marker.each do |marker, ops|
        check "#{ops.size} LB + #{marker} plates"
      end
      image 'Actions/Plating/put_plate_incubator.JPG'
    end

    # Clean up
    show do
      title 'Clean up'
      check 'Put all cuvettes into biohazardous waste.'
      check 'Discard empty electrocompetent aliquot tubes into waste bin.'
      check 'Return the styrofoam ice block and the aluminum tube rack.'
      image 'Actions/Transformation/dump_dirty_cuvettes.jpg'
    end

    # Move items
    operations.running.each do |op|
        op.output(OUTPUT).item.move '37C shaker'
    end

    give_happy_birthday

    # Store dna stocks
    all_stocks = operations.running.map { |op| [op.input(INPUT).item, op.temporary[:old_stock]] }.flatten.uniq
    all_stocks.compact!
    release all_stocks, interactive: true, method: 'boxes'

    {}
  end
end
