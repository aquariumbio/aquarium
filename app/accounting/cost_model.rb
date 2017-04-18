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
          materials: primer_costs.inject{|sum,x| sum+x } * 1.096,
          labor: 0.79
        }

      when ["get_primer","received and stocked"] then basic(:primer_ids,0.14,2.58)

      # FRAGMENT CONSTRUCTION ##############################################################################

      when ["PCR","pcr"]          then basic(:fragments,1.04,4.34)
      when ["run_gel","gel run"]  then basic(:fragments,1.04,2.32)
      when ["cut_gel","gel cut"]  then basic(:fragments,0.14,2.1)
      when ["cut_gel","failed"]   then nothing
      when ["purify_gel","done"]  then basic(:fragments,2.35,6.96)

      # GIBSON ASSEMBLY ####################################################################################

      when ["gibson","gibson"]                           then basic(:default,3.75,7.93)
      when ["ecoli_transformation","transformed"]        then basic(:default,2.77,6.09)
      when ["plate_ecoli_transformation","plated"]       then basic(:default,0.82,3.09)
      when ["image_plate","imaged and stored in fridge"] then basic(:default,0.02,0.78)
      when ["image_plate","no colonies"]                 then basic(:default,0.0,0.78)

      # GOLDEN GATE ASSEMBLY ####################################################################################

      when ["golden_gate","golden gate"]                    then basic(:default,10.58,11.77)
      when ["ecoli_transformation_stripwell","transformed"] then basic(:default,2.77,6.09)
      when ["plate_ecoli_transformation","plated"]          then basic(:default,0.82,3.09)
      when ["image_plate","imaged and stored in fridge"]    then basic(:default,0.02,0.78)
      when ["image_plate","no colonies"]                    then basic(:default,0.0,0.78)

      # PLASMID VERIFICATION ################################################################################
      when ["start_overnight_plate","overnight"] 
        if simple_spec[:num_colonies]
          n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        else
          n = 1
        end
        {
          materials: 0.6 * n,
          labor: 3.88 * n * labor_rate
        }

      when ["miniprep","plasmid extracted"]  
        if simple_spec[:num_colonies]
          n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        else
          n = 1
        end
        {
          materials: 1.57 * n,
          labor: 12.13 * n * labor_rate
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
          materials: 6.93 * n,
          labor: 7.6 * n * labor_rate
        }

      when ["upload_sequencing_results","results back"] then basic(:default,0.0,0.6)

      # GLYCEROL STOCK ########################################################################################

      when ["overnight_suspension", "overnight"]  then basic(:item_ids,0.08,1.95)
      when ["glycerol_stock","done"] 
        if simple_spec[:num_colonies]
          n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        else
          n = 1
        end
        {
          materials: 0.71 * n,
          labor: 2.01 * n * labor_rate
        }


      when ["discard_item","discarded"]                 then basic(:default,0.0, 0.51)

      # MAXIPREP ############################################################################################

      when ["start_overnight_glycerol_stock","overnight"] then basic(:default,9.83,9.09)
      when ["maxiprep","plasmid extracted"]               then basic(:default,40.5,40.1)

      # AGRO TRANSFORMATION #################################################################################

      when ["agro_transformation", "transformed"]  then basic(:default,2.77,18.0)
      when ["plate_agro_transformation", "plated"] then basic(:default,0.82,3.2)

      # STREAK PLATE ########################################################################################

      when ["streak_yeast_plate","streaked"] then basic(:item_ids,0.39,7.4)
        
      # VERIFICATION DIGEST #################################################################################
      
      when ["restriction_digest","digested"] then basic(:default,0.69,13.7)
      when ["fragment_analyzing","correct"], 
           ["fragment_analyzing","partial"], 
           ["fragment_analyzing","incorrect"]
        then basic(:default,0.55,2.63)

      # USED IN ECOLI/YEAST TRANSFORMATION, GIBSON ASSEMBLY, and YEAST MATING ###############################

      when ["image_plate","imaged and stored in fridge"]
          shared({
            "Ecoli Transformation" => :plasmid_item_ids,
            "Agro Transformation" => :plasmid_item_ids,
            "Gibson Assembly" => :default,
            "Yeast Mating" => :single_sample,
            "Yeast Transformation" => :yeast_transformed_strain_ids
          },0.03,0.7)

      # YEAST COMPETENT CELLS ################################################################################

      when ["overnight_suspension_collection","overnight"]         then basic(:yeast_strain_ids,0.08,5.25)
      when ["inoculate_large_volume_growth","large volume growth"] then basic(:yeast_strain_ids,2.33,4.89)
      when ["make_yeast_competent_cell","done"]                    then basic(:yeast_strain_ids,0.69,13.96)

      # YEAST TRANSFORMATION #################################################################################

      when ["digest_plasmid_yeast_transformation","plasmid digested"] then basic(:yeast_transformed_strain_ids,1.39,3.5)
      when ["make_antibiotic_plate","plate made"]                     then basic(:yeast_transformed_strain_ids,2.11,2.82)
      when ["yeast_transformation","transformed"]                     then basic(:yeast_transformed_strain_ids,1.11,9.99)
      when ["plate_yeast_transformation","plated"]                    then basic(:yeast_transformed_strain_ids,0.0,1.62)


      # YEAST STRAIN QC #######################################################################################

      when ["make_yeast_lysate","lysate"]
        n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        {
          materials: 0.08 * n,
          labor: 3.23 * n * labor_rate
        }

      when ["yeast_colony_PCR","pcr"]
        n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        {
          materials: 0.27 * n,
          labor: 3.09 * n * labor_rate
        }

      when ["fragment_analyzing","gel imaged"]
        n = simple_spec[:num_colonies].inject { |sum,x| sum+x }
        {
          materials: 0.55 * n,
          labor: 2.63 * n * labor_rate
        }
      
      # YEAST MATING #######################################################################################
      # All the yeast mating task are single sample.
      # Even the yeast_mating_strain_ids is an array of size two, they are counted as single sample.

      when ["yeast_mating","mating"]         then basic(:single_sample,2.94,10.27)
      when ["streak_yeast_plate","streaked"] then basic(:single_sample,0.39,7.4)
      
      # YEAST CYTOMETRY ####################################################################################

      when ["overnight_suspension_divided_plate_to_deepwell","overnight"]      then basic(:yeast_strain_ids,2.16,4.75)
      when ["dilute_yeast_culture_deepwell_plate","diluted"] then basic(:yeast_strain_ids,2.16,2.42)
      when ["cytometer_reading","cytometer read"] then basic(:yeast_strain_ids,1.32,2.4)

      when ["make_yeast_lysate","lysate"]      then basic(:yeast_plate_ids,0.08,3.23)
      when ["yeast_colony_PCR","pcr"]          then basic(:yeast_plate_ids,0.27,3.09)
      when ["fragment_analyzing","gel imaged"] then basic(:yeast_plate_ids,0.55,2.63)

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

