puts "Migrating sample types to json data format"

(SampleType.all.reject { |st| st.datatype }).each do |st|

  dt = {}

  (1..8).each do |i|
    type = st.fieldtype(i)[0] 
    if type == "number" || type == "string" || type == "url"
      dt[st.fieldname(i).to_sym] = { type: type }
    end
  end

  st.datatype = dt.to_json
  st.save

end

