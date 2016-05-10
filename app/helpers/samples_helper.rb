module SamplesHelper

  def self.upgrade s, st

    (1..8).each do |i|
      n = st.fieldname i       
      t = st.fieldtype i 
      if t == [ 'string' ] || t == [ 'url' ] || t == [ 'number' ]
        fv = s.field_values.new name: n, value: s["field#{i}"].to_s
      elsif t != [ 'not used' ] && s["field#{i}"] && s["field#{i}"] != '-none-' && s["field#{i}"] != '' && s["field#{i}"] != 'NA'
        c = Sample.find_by_name(s["field#{i}"])
        @messages << "Sample #{s.id}: #{n}: Could not find '#{s["field#{i}"]}' with type in #{t}." unless c
        fv = s.field_values.new(name: n, child_sample_id: c.id) if c
      end
      fv.save if fv
    end

    return s

  end

  def self.upgrade_by_st st, num=nil

    @messages ||= []
    n = 0;

    st.samples.each do |s|
      n += 1
      return @messages if num && n > num
      self.upgrade s, st
    end

    @messages

  end

  def self.reset_by_st st

    @messages ||= []    

    st.samples.each do |s|
      s.field_values.each do |fv|
        fv.destroy
      end
    end

    return @messages

  end

  def self.upgrade_all
    SampleType.all.each do |st|
      self.upgrade_by_st st
    end
  end

end
