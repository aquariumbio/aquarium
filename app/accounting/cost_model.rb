module CostModel

  def cost_model(protocol, status)

    case [protocol, status]

      # PRIMER_ORDER ######################################################################################

    when %w[order_primer ordered]
      primers = simple_spec[:primer_ids].collect { |pid| Sample.find(pid) }
      primer_costs = primers.collect do |p|
        length = p.properties['Overhang Sequence'].length + p.properties['Anneal Sequence'].length
        if length <= 60
          length * Parameter.get_float('short primer cost')
        elsif length <= 90
          length * Parameter.get_float('medium primer cost')
        else
          length * Parameter.get_float('long primer cost')
        end
      end
      {
        materials: primer_costs.inject { |sum, x| sum + x } * 1.096,
        labor: 0.79
      }

    when ['get_primer', 'received and stocked'] then basic(:primer_ids, 0.14, 2.58)

      # FRAGMENT CONSTRUCTION ##############################################################################

    when %w[PCR pcr] then basic(:fragments, 1.04, 4.34)
    when ['run_gel', 'gel run']  then basic(:fragments, 1.04, 2.32)
    when ['cut_gel', 'gel cut']  then basic(:fragments, 0.14, 2.1)
    when %w[cut_gel failed]   then nothing
    when %w[purify_gel done]  then basic(:fragments, 2.35, 6.96)

      # GIBSON ASSEMBLY ####################################################################################

    when %w[gibson gibson]                           then basic(:default, 3.75, 7.93)
    when %w[ecoli_transformation transformed]        then basic(:default, 2.77, 6.09)
    when %w[plate_ecoli_transformation plated]       then basic(:default, 0.82, 3.09)
    when ['image_plate', 'imaged and stored in fridge'] then basic(:default, 0.02, 0.78)
    when ['image_plate', 'no colonies']                 then basic(:default, 0.0, 0.78)

      # GOLDEN GATE ASSEMBLY ####################################################################################

    when ['golden_gate', 'golden gate'] then basic(:default, 10.58, 11.77)
    when %w[ecoli_transformation_stripwell transformed] then basic(:default, 2.77, 6.09)
    when %w[plate_ecoli_transformation plated]          then basic(:default, 0.82, 3.09)
    when ['image_plate', 'imaged and stored in fridge']    then basic(:default, 0.02, 0.78)
    when ['image_plate', 'no colonies']                    then basic(:default, 0.0, 0.78)

      # E coli QC #######################################################################################

    when %w[make_ecoli_lysate lysate]
      n = simple_spec[:num_colonies].inject { |sum, x| sum + x }
      {
        materials: 0.08 * n,
        labor: 0.48 * n * labor_rate
      }

    when %w[ecoli_colony_PCR pcr]
      n = simple_spec[:num_colonies].inject { |sum, x| sum + x }
      {
        materials: 0.27 * n,
        labor: 0.46 * n * labor_rate
      }

    when ['fragment_analyzing_ecoli', 'gel imaged']
      n = simple_spec[:num_colonies].inject { |sum, x| sum + x }
      {
        materials: 0.55 * n,
        labor: 0.39 * n * labor_rate
      }

      # PLASMID VERIFICATION ################################################################################
    when %w[start_overnight_plate overnight]
      n = if simple_spec[:num_colonies]
            simple_spec[:num_colonies].inject { |sum, x| sum + x }
          else
            1
          end
      {
        materials: 0.6 * n,
        labor: 3.88 * n * labor_rate
      }

    when ['miniprep', 'plasmid extracted']
      n = if simple_spec[:num_colonies]
            simple_spec[:num_colonies].inject { |sum, x| sum + x }
          else
            1
          end
      {
        materials: 1.57 * n,
        labor: 12.13 * n * labor_rate
      }

    when ['sequencing', 'send to sequencing']
      n = 0
      if simple_spec[:num_colonies] # its a "Plasmid Verification" task
        m = simple_spec[:num_colonies].length
        (0..m - 1).each do |i|
          n += simple_spec[:num_colonies][i] * simple_spec[:primer_ids][i].length
        end
      else # its a "Sequencing" task
        simple_spec[:primer_ids].each do |primer_list|
          n += primer_list.length
        end
      end
      {
        materials: 6.93 * n,
        labor: 7.6 * n * labor_rate
      }

    when ['upload_sequencing_results', 'results back'] then basic(:default, 0.0, 0.6)

      # GLYCEROL STOCK ########################################################################################

    when %w[overnight_suspension overnight] then basic(:item_ids, 0.08, 1.95)
    when %w[glycerol_stock done]
      n = if simple_spec[:num_colonies]
            simple_spec[:num_colonies].inject { |sum, x| sum + x }
          else
            1
          end
      {
        materials: 0.71 * n,
        labor: 2.01 * n * labor_rate
      }

    when %w[discard_item discarded] then basic(:default, 0.0, 0.51)

      # MIDIPREP ############################################################################################

    when %w[plate_midiprep plated] then basic(:default, 0.83, 5.52)
    when ['image_plate', 'imaged and stored in fridge'] then basic(:default, 0.02, 0.675)
    when %w[image_plate canceled] then basic(:default, 0.02, 0.675)
    when ['small_inoculation_midiprep', 'small overnight'] then basic(:default, 0.29, 2.08)
    when ['large_inoculation_midiprep', 'large overnight'] then basic(:default, 4.26, 6.05)
    when ['midiprep', 'plasmid extracted']                 then basic(:default, 16.03, 43.33)

      # MAXIPREP ############################################################################################

    when %w[plate_maxiprep plated] then basic(:default, 0.80, 5.52)
    when ['image_plate', 'imaged and stored in fridge'] then basic(:default, 0.02, 0.675)
    when %w[image_plate canceled] then basic(:default, 0.02, 0.675)
    when ['small_inoculation_maxiprep', 'small overnight'] then basic(:default, 0.10, 2.08)
    when ['large_inoculation_maxiprep', 'large overnight'] then basic(:default, 10.31, 6.05)
    when ['maxiprep', 'plasmid extracted']                 then basic(:default, 40.5, 40.14)

      # AGRO TRANSFORMATION #################################################################################

    when %w[agro_transformation transformed]  then basic(:default, 2.77, 18.0)
    when %w[plate_agro_transformation plated] then basic(:default, 0.82, 3.2)

      # STREAK PLATE ########################################################################################

    when %w[streak_yeast_plate streaked] then basic(:item_ids, 0.39, 7.4)

      # VERIFICATION DIGEST #################################################################################

    when %w[restriction_digest digested] then basic(:default, 0.69, 13.7)
    when %w[fragment_analyzing correct],
           %w[fragment_analyzing partial],
           %w[fragment_analyzing incorrect]
        then basic(:default, 0.55, 2.63)

      # USED IN ECOLI/YEAST TRANSFORMATION, GIBSON ASSEMBLY, and YEAST MATING ###############################

    when ['image_plate', 'imaged and stored in fridge']
      shared({
               'Ecoli Transformation' => :plasmid_item_ids,
               'Agro Transformation' => :plasmid_item_ids,
               'Gibson Assembly' => :default,
               'Yeast Mating' => :single_sample,
               'Yeast Transformation' => :yeast_transformed_strain_ids
             }, 0.03, 0.7)

      # YEAST COMPETENT CELLS ################################################################################

    when %w[overnight_suspension_collection overnight] then basic(:yeast_strain_ids, 0.08, 5.25)
    when ['inoculate_large_volume_growth', 'large volume growth'] then basic(:yeast_strain_ids, 2.33, 4.89)
    when %w[make_yeast_competent_cell done]                    then basic(:yeast_strain_ids, 0.69, 13.96)

      # YEAST TRANSFORMATION #################################################################################

    when ['digest_plasmid_yeast_transformation', 'plasmid digested'] then basic(:yeast_transformed_strain_ids, 1.39, 3.5)
    when ['make_antibiotic_plate', 'plate made']                     then basic(:yeast_transformed_strain_ids, 2.11, 2.82)
    when %w[yeast_transformation transformed]                     then basic(:yeast_transformed_strain_ids, 1.11, 9.99)
    when %w[plate_yeast_transformation plated]                    then basic(:yeast_transformed_strain_ids, 0.0, 1.62)

      # YEAST STRAIN QC #######################################################################################

    when %w[make_yeast_lysate lysate]
      n = simple_spec[:num_colonies].inject { |sum, x| sum + x }
      {
        materials: 0.08 * n,
        labor: 3.23 * n * labor_rate
      }

    when %w[yeast_colony_PCR pcr]
      n = simple_spec[:num_colonies].inject { |sum, x| sum + x }
      {
        materials: 0.27 * n,
        labor: 3.09 * n * labor_rate
      }

    when ['fragment_analyzing', 'gel imaged']
      n = simple_spec[:num_colonies].inject { |sum, x| sum + x }
      {
        materials: 0.55 * n,
        labor: 2.63 * n * labor_rate
      }

      # YEAST MATING #######################################################################################
      # All the yeast mating task are single sample.
      # Even the yeast_mating_strain_ids is an array of size two, they are counted as single sample.

    when %w[yeast_mating mating]         then basic(:single_sample, 2.94, 10.27)
    when %w[streak_yeast_plate streaked] then basic(:single_sample, 0.39, 7.4)

      # YEAST CYTOMETRY ####################################################################################

    when %w[overnight_suspension_divided_plate_to_deepwell overnight] then basic(:yeast_strain_ids, 2.16, 4.75)
    when %w[dilute_yeast_culture_deepwell_plate diluted] then basic(:yeast_strain_ids, 2.16, 2.42)
    when ['cytometer_reading', 'cytometer read'] then basic(:yeast_strain_ids, 1.32, 2.4)

    when %w[make_yeast_lysate lysate]      then basic(:yeast_plate_ids, 0.08, 3.23)
    when %w[yeast_colony_PCR pcr]          then basic(:yeast_plate_ids, 0.27, 3.09)
    when ['fragment_analyzing', 'gel imaged'] then basic(:yeast_plate_ids, 0.55, 2.63)

      # DIRECT PURCHASES ##################################################################################

    when %w[direct_purchase purchased]
      {
        materials: simple_spec[:materials],
        labor: simple_spec[:labor] * labor_rate
      }
    when %w[tasks_inputs purchased]
      {
        materials: simple_spec[:materials],
        labor: 0
      }

    else nothing

    end

  end

  def nothing
    { materials: 0, labor: 0 }
  end

  def one(mat, lab, warn = false)
    puts "WARNING: Cost Model Error: Could not find key in specification #{simple_spec}. Assuming single sample." if warn
    { materials: mat, labor: lab * labor_rate }
  end

  def labor_rate
    Parameter.get_float('labor rate')
  end

  def basic(key, mat, lab)
    if simple_spec[key]
      num = simple_spec[key].length
      {
        materials: mat * num,
        labor: lab * num * labor_rate
      }
    else
      one mat, lab, true
    end
  end

  def shared(hash, mat, lab)
    key = hash[task_prototype.name]
    if key
      if key == :default
        one mat, lab
      else
        basic key, mat, lab
      end
    else
      one mat, lab, true
    end
  end

end
