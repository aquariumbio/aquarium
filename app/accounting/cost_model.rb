module CostModel

  def cost_model protocol, status

    case [protocol,status]

      # PRIMER_ORDER ######################################################################################

      when ["order_primer","ordered"]
        primers = simple_spec[:primer_ids].collect { |pid| Sample.find(pid) }
        primer_costs = primers.collect { |p| 
          length = p.properties["Overhang Sequence"].length + p.properties["Anneal Sequence"].length
          if length <= 60
            length * 0.15
          elsif length <= 90
            length * 0.34
          else
            length * 0.55
          end
        }
        { 
          materials: primer_costs.inject{|sum,x| sum+x },
          labor: 0.0 * primers.length * labor_rate
        }

      when ["get_primer","received and stocked"] then basic(:primer_ids,0.05,3.6)

      # FRAGMENT CONSTRUCTION ##############################################################################

      when ["PCR","pcr"]          then basic(:fragments,1.26,4.6)
      when ["run_gel","gel run"]  then basic(:fragments,0.31,2.0)
      when ["cut_gel","gel cut"]  then basic(:fragments,0.10,2.0)
      when ["cut_gel","failed"]   then nothing
      when ["purify_gel","done"]  then basic(:fragments,1.98,7.1)

      # GIBSON ASSEMBLY ####################################################################################

      when ["gibson","gibson"]                           then basic(:default,1.85,5.2)
      when ["ecoli_transformation","transformed"]        then basic(:default,1.80,3.0)
      when ["plate_ecoli_transformation","plated"]       then basic(:default,0.77,1.9)
      when ["image_plate","imaged and stored in fridge"] then basic(:default,0.03,0.7)
      when ["image_plate","no colonies"]                 then basic(:default,0.0,0.7)

      # PLASMID VERIFICATION ################################################################################

      when ["start_overnight_plate","overnight"]        then basic(:plate_ids,0.93,1.7)
      when ["miniprep","plasmid_extracted"]             then basic(:plate_ids,1.35,6.4)
      when ["sequencing","sent to sequencing"]          then basic(:plate_ids,6.12,2.6)
      when ["upload_sequencing_results","results back"] then nothing
      when ["glycerol_stock","done"]                    then basic(:plate_ids,2.69,1.7)
      when ["discard_item","discarded"]                 then nothing

      # STREAK PLATE ########################################################################################

      when ["streak_yeast_plate","streaked"] then basic(:item_ids,1.12,5.8)

      # USED IN ECOLI/YEAST TRANSFORMATION, GIBSON ASSEMBLY, and YEAST MATING ###############################

      when ["image_plate","imaged and stored in fridge"]
          shared({
            "Ecoli Transformation" => :plasmid_item_ids,
            "Gibson Assembly" => :default,
            "Yeast Mating" => :yeast_mating_strain_ids,
            "Yeast Transformation" => :yeast_transformed_strain_ids
          },0.03,0.7)

      # YEAST COMPETENT CELLS ################################################################################

      when ["overnight_suspension_collection","overnight"]         then basic(:yeast_strain_ids,1.18,4.7)
      when ["inoculate_large_volume_growth","large_volume_growth"] then basic(:yeast_strain_ids,1.00,4.2)
      when ["make_yeast_competent_cells","done"]                   then basic(:yeast_strain_ids,1.55,16)

      # YEAST TRANSFORMATION #################################################################################

      when ["digest_plasmid_yeast_transformation","plasmid_digested"] then basic(:yeast_transformed_strain_ids,0.91,3.5)
      when ["make_antibiotic_plate","plate_made"]                     then basic(:yeast_transformed_strain_ids,3.02,1.4)
      when ["yeast_transformation","transformed"]                     then basic(:yeast_transformed_strain_ids,1.48,11)
      when ["plate_yeast_transformation","plated"]                    then basic(:yeast_transformed_strain_ids,0,2)

      # YEAST STRAIN QC #######################################################################################

      when ["make_yeast_lysate","lysate"]      then basic(:yeast_plate_ids,0.10,3.3)
      when ["yeast_colony_PCR","pcr"]          then basic(:yeast_plate_ids,0.43,2.2)
      when ["fragment_analyzing","gel_imaged"] then basic(:yeast_plate_ids,0.35,1.0)

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
    20.97 / 60
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

