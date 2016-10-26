module CostModel

  def cost_model protocol, status

    case [protocol,status]

      # PRIMER_ORDER ######################################################################################

      when ["order_primer","ordered"]
        primers = simple_spec[:primer_ids].collect { |pid| Sample.find(pid) }
        primer_costs = primers.collect { |p| 
          length = p.properties["Overhang Sequence"].length + p.properties["Anneal Sequence"].length
          if length <= 60
            length * Parameter.get_float('short primer cost')
          elsif length <= 90
            length * Parameter.get_float('medium primer cost')
          else
            length * Parameter.get_float('long primer cost')
          end
        }
        { 
          materials: primer_costs.inject{|sum,x| sum+x },
          labor: 0.0
        }

      when ["get_primer","received and stocked"] then basic(:primer_ids,0.09,3.5)

      # FRAGMENT CONSTRUCTION ##############################################################################

      when ["PCR","pcr"]          then basic(:fragments,0.94,5.0)
      when ["run_gel","gel run"]  then basic(:fragments,0.31,2.7)
      when ["cut_gel","gel cut"]  then basic(:fragments,0.10,2.1)
      when ["cut_gel","failed"]   then nothing
      when ["purify_gel","done"]  then basic(:fragments,1.99,7.5)

      # GIBSON ASSEMBLY ####################################################################################

      when ["gibson","gibson"]                           then basic(:default,2.85,5.3)
      when ["ecoli_transformation","transformed"]        then basic(:default,1.72,3.3)
      when ["plate_ecoli_transformation","plated"]       then basic(:default,0.71,2.0)
      when ["image_plate","imaged and stored in fridge"] then basic(:default,0.03,0.7)
      when ["image_plate","no colonies"]                 then basic(:default,0.0,0.7)

      # PLASMID VERIFICATION ################################################################################
      when ["start_overnight_plate","overnight"] 
        if simple_spec[:num_colonies]
          n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        else
          n = 1
        end
        {
          materials: 0.11 * n,
          labor: 3.1 * n * labor_rate
        }

      when ["miniprep","plasmid extracted"]  
        if simple_spec[:num_colonies]
          n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        else
          n = 1
        end
        {
          materials: 1.35 * n,
          labor: 9.9 * n * labor_rate
        }

      when ["sequencing","send to sequencing"]
        n = 0
        if simple_spec[:num_colonies] # its a "Plasmid Verification" task
          m = simple_spec[:num_colonies].length
          (0..m-1).each do |i|
            n += simple_spec[:num_colonies][i] * simple_spec[:primer_ids][i].length
          end
        else # its a "Sequencing" task
          simple_spec[:primer_ids].each do |primer_list|
            n += primer_list.length
          end          
        end
        {
          materials: 6.0 * n,
          labor: 5.3 * n * labor_rate
        }

      when ["upload_sequencing_results","results back"] then nothing

      when ["glycerol_stock","done"] 
        if simple_spec[:num_colonies]
          n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        else
          n = 1
        end
        {
          materials: 0.53 * n,
          labor: 1.9 * n * labor_rate
        }

      when ["discard_item","discarded"]                 then nothing

      # STREAK PLATE ########################################################################################

      when ["streak_yeast_plate","streaked"] then basic(:item_ids,0.13,5.0)
        
      # VERIFICATION DIGEST #################################################################################
      
      when ["restriction_digest","digested"] then basic(:default,0.95,5.7)
      when ["fragment_analyzing","correct"], 
           ["fragment_analyzing","partial"], 
           ["fragment_analyzing","incorrect"]
        then basic(:default,0.43,3.1)

      # USED IN ECOLI/YEAST TRANSFORMATION, GIBSON ASSEMBLY, and YEAST MATING ###############################

      when ["image_plate","imaged and stored in fridge"]
          shared({
            "Ecoli Transformation" => :plasmid_item_ids,
            "Gibson Assembly" => :default,
            "Yeast Mating" => :single_sample,
            "Yeast Transformation" => :yeast_transformed_strain_ids
          },0.03,0.7)

      # YEAST COMPETENT CELLS ################################################################################

      when ["overnight_suspension_collection","overnight"]         then basic(:yeast_strain_ids,0.06,5.4)
      when ["inoculate_large_volume_growth","large volume growth"] then basic(:yeast_strain_ids,0.28,3.8)
      when ["make_yeast_competent_cell","done"]                    then basic(:yeast_strain_ids,0.33,16.4)

      # YEAST TRANSFORMATION #################################################################################

      when ["digest_plasmid_yeast_transformation","plasmid digested"] then basic(:yeast_transformed_strain_ids,1.25,4.4)
      when ["make_antibiotic_plate","plate made"]                     then basic(:yeast_transformed_strain_ids,2.09,1.4)
      when ["yeast_transformation","transformed"]                     then basic(:yeast_transformed_strain_ids,0.91,11.3)
      when ["plate_yeast_transformation","plated"]                    then basic(:yeast_transformed_strain_ids,0,2)


      # YEAST STRAIN QC #######################################################################################

      when ["make_yeast_lysate","lysate"]
        n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        {
          materials: 0.10 * n,
          labor: 4.0 * n * labor_rate
        }

      when ["yeast_colony_PCR","pcr"]
        n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        {
          materials: 0.43 * n,
          labor: 3.1 * n * labor_rate
        }

      when ["fragment_analyzing","gel imaged"]
        n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        {
          materials: 0.43 * n,
          labor: 3.1 * n * labor_rate
        }
      
      # YEAST MATING #######################################################################################
      # All the yeast mating task are single sample.
      # Even the yeast_mating_strain_ids is an array of size two, they are counted as single sample.

      when ["yeast_mating","mating"]      then basic(:single_sample,0.90,3.3)
      when ["streak_yeast_plate","plate"] then basic(:single_sample,0,5)
      
      # YEAST CYTOMETRY ####################################################################################

      when ["overnight_suspension_divided_plate_to_deepwell","overnight"]      then basic(:yeast_strain_ids,1.53,2.7)
      when ["dilute_yeast_culture_deepwell_plate","diluted"] then basic(:yeast_strain_ids,1.53,2.4)
      when ["cytometer_reading","cytometer read"] then basic(:yeast_strain_ids,0.02,2.9)

      when ["make_yeast_lysate","lysate"]      then basic(:yeast_plate_ids,0.10,4.0)
      when ["yeast_colony_PCR","pcr"]          then basic(:yeast_plate_ids,0.43,3.1)
      when ["fragment_analyzing","gel imaged"] then basic(:yeast_plate_ids,0.35,3.1)

      # DIRECT PURCHASES ##################################################################################

      when ["direct_purchase", "purchased"]
        {
          materials: simple_spec[:materials],
          labor: simple_spec[:labor] * labor_rate
        }
      when ["tasks_inputs", "purchased"]
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

  def one mat, lab, warn=false
    if warn
      puts "WARNING: Cost Model Error: Could not find key in specification #{simple_spec}. Assuming single sample."
    end
    { materials: mat, labor: lab * labor_rate }
  end

  def labor_rate
    Parameter.get_float('labor rate')
  end

  def basic key, mat, lab
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

  def shared hash, mat, lab
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

