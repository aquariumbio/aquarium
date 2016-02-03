module CostModel

  def cost_model

    return {

      "miniprep" => {
        "plasmid extracted" => lambda { |spec| { materials: 1.00, labor: 1.00 } }
      },

      "get_primer" => {

        "received and stocked" => lambda { |spec|
          puts spec
          primers = spec[:primer_ids].collect { |pid| Sample.find(pid) }
          primer_costs = primers.collect { |p| 
            length = p.properties["Overhang Sequence"].length + p.properties["Anneal Sequence"].length
            if length <= 60
              length * 0.18
            elsif length <= 90
              length * 0.37
            else
              length * 0.58
            end
          }
          { 
            materials: primer_costs.inject{|sum,x| sum+x },
            labor: 1.0 * primers.length
          }
        }

      }

    }

  end

end