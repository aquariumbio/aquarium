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

      when ["start_overnight_plate","overnight"]        then basic(:plate_ids,0.11,3.1)
      when ["miniprep","plasmid extracted"]             then basic(:plate_ids,1.35,9.9)
      when ["sequencing","send to sequencing"]          then basic(:plate_ids,4.8,5.3)
      when ["upload_sequencing_results","results back"] then nothing
      when ["glycerol_stock","done"]                    then basic(:plate_ids,0.53,1.9)
      when ["discard_item","discarded"]                 then nothing

      # STREAK PLATE ########################################################################################

      when ["streak_yeast_plate","streaked"] then basic(:item_ids,0.13,5.0)

      # USED IN ECOLI/YEAST TRANSFORMATION, GIBSON ASSEMBLY, and YEAST MATING ###############################

      when ["image_plate","imaged and stored in fridge"]
          shared({
            "Ecoli Transformation" => :plasmid_item_ids,
            "Gibson Assembly" => :default,
            "Yeast Mating" => :yeast_mating_strain_ids,
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

      when ["make_yeast_lysate","lysate"]      then basic(:yeast_plate_ids,0.10,4.0)
      when ["yeast_colony_PCR","pcr"]          then basic(:yeast_plate_ids,0.43,3.1)
      when ["fragment_analyzing","gel imaged"] then basic(:yeast_plate_ids,0.35,3.1)

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

