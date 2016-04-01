module CostModel

  def cost_model

    return {

      # PRIMER_ORDER ######################################################################################

      "order_primer" => { 
        "ordered" => lambda { |spec|
          primers = spec[:primer_ids].collect { |pid| Sample.find(pid) }
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
        }
      },

      "get_primer" => { 
        "received and stocked" => basic(:primer_ids,0.05,3.6)
      },

      # FRAGMENT CONSTRUCTION ##############################################################################

      "PCR" => { 
        "pcr" => basic(:framents,1.26,4.6)
        }
      },

      "pour_gel" => { 
        "gel run" => basic(:framents,0.31,2.0)
      },

      "cut_gel" => {
        "get cut" => basic(:framents,0.10,2.0),
        "failed" => nothing
      },

      "gel_purify" => {
        "done" => basic(:framents,1.98,7.1)
      },

      # GIBSON ASSEMBLY ####################################################################################

      "gibson" => {
        "gibson" => basic(:plasmids,1.85,5.2)
      },

      "ecoli_transformation" => {
        "transformed" => basic(:plasmids,1.80,3.0),
        "plated" => basic(:plasmids,0.77,1.9)
      },

      "image_plate" => {
        "imaged and stored in fridge" => basic(:plasmids,0.03,0.7),
        "no colonies" => basic(:plasmids,0.0,0.7)
      },

      # PLASMID VERIFICATION ################################################################################

      "start_overnight_plate" => {
        "overnight" => basic(:plate_ids,0.93,1.7)
      },

      "miniprep" => {
        "plasmid_extracted" => basic(:plate_ids,1.35,6.4)
      },

      "sequencing" => {
        "sent to sequencing" => basic(:plate_ids,6.12,2.6)
      },

      "upload_sequencing_results" => {
        "results back" => nothing
      },

      "glycerol_stock" => {
        "done" => basic(:plate_ids,2.69,1.7)
      }, 

      "discard_item" => {
        "discarded" => nothing
      },

      # STREAK PLATE ########################################################################################

      "streak_yeast_plate" => {
        "streaked" => basic(:item_ids,1.12,5.8)
      }, 

      # USED IN ECOLI/YEAST TRANSFORMATION, GIBSON ASSEMBLY, and YEAST MATING ###############################

      "image_plate" => {
        "imaged and stored in fridge" => shared({
            "Ecoli Transformation" => :plasmid_item_ids,
            "Gibson Assembly" => :default,
            "Yeast Mating" => :yeast_mating_strain_ids,
            "Yeast Transformation" => :yeast_transformed_strain_ids
          },0.03,0.7)
      },

      # YEAST COMPETENT CELLS ################################################################################

      "overnight_suspension_collection" => {
        "overnight" => basic(:yeast_strain_ids,1.18,4.7)
      },

      "inoculate_large_volume_growth" => {
        "large_volume_growth" => basic(:yeast_strain_ids,1.00,4.2)
      },

      "make_yeast_competent_cells" => {
        "done" => basic(:yeast_strain_ids,1.55,16)
      },

      # YEAST TRANSFORMATION #################################################################################

      "digest_plasmid_yeast_transformation" => {
        "plasmid_digested" => basic(:yeast_transformed_strain_ids,0.91,3.5)
      },

      # WAITING FOR THIS ONE TO HAVE A TASK STATUS UPDATE
      # "make_antibiotic_plate" => {
      # },

      "yeast_transformation" => {
        "transformed" => basic(:yeast_transformed_strain_ids,1.48,11)
      },

      "plate_yeast_transformation" => {
        "plated" => basic(:yeast_transformed_strain_ids,0,2)
      },

      # YEAST STRAIN QC #######################################################################################

      "make_yeast_lysate" => {
        "lysate" =>  basic(:yeast_plate_ids,0.10,3.3)
      },

      "yeast_colony_PCR" => {
        "pcr" => basic(:yeast_plate_ids,0.43,2.2)
      },

      "fragment_analyzing" => {
        "gel_imaged" => basic(:yeast_plate_ids,0.35,1.0)
      }

    }

  end

  def nothing
    lambda { |spec| { materials: 0, labor: 0 } }
  end

  def one mat, lab, warn=false
    if warn
      puts "WARNING: Cost Model Error: Could not find key #{key} in specification #{spec}. Assuming single sample."
    end
    { materials: mat, labor: lab * labor_rate }
  end

  def labor_rate
    20.97 / 60
  end

  def basic key, mat, lab
    lambda { |spec| 
      if spec[key]
        num = spec[key].length
        {
          materials: mat * num,
          labor: lab * num * labor_rate
        }      
      else
        one mat, lab, true
      end
    }
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

