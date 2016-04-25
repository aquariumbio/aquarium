class TreeController < ApplicationController

  def tree
  end

  def all

    sts = SampleType.includes(:samples).all

    result = {}

    sts.each { |st|
      result[st.name] = st.samples.collect { |s|
        "#{s.id}: #{s.name}"
      }
    }

    render json: result

  end

  def projects
    render json: {
      user: Sample.where(user_id: current_user.id)
                  .uniq
                  .pluck(:project)
                  .sort
                  .collect { |p| { name: p, selected: false } },
      all:  Sample.uniq.pluck(:project)
                  .sort
                  .collect { |p| { name: p, selected: false } }
    }
  end

  def samples_for_tree
    render json: Sample.includes(:sample_type)
                       .where(project: params[:project], sample_type_id: params[:sample_type_id].to_i)
                       .reverse
  end

  def subsamples
    render json: Sample.find(params[:id]).properties
  end

  def sample_name_from_identifier str
    parts = str.split(": ")
    if parts.length == 0
      ""
    elsif parts.length == 1
      parts[0]
    else
      parts[1..-1].join(": ")
    end
  end

  def make_sample samp

    s = samp[:copy]

    sample = Sample.new({
      name: s[:name],
      project: s[:project],
      description: s[:description],
      user_id: current_user.id,
      sample_type_id: samp[:sample_type][:id]
    })

    (1..8).each do |i|

      f = "field#{i}"

      if s[f].respond_to? :has_key?

        if s[f][:choice] == 'existing'
          if s[f][:existing]
            subsample_name = sample_name_from_identifier(s[f][:existing])
            sample[f] = subsample_name
          else
            sampe[f] = ""
          end
        else # new
          sample[f] = s[f][:new][:name]
        end

      else
        sample[f] = s[f]
      end

    end

    return sample

  end

  def save_new_aux samp

    (1..8).each do |i|
      f = samp[:copy]["field#{i}"]
      if f.respond_to?(:has_key?) && f[:new]
        s = save_new_aux f[:new]
        f[:new][:name] = s.name
      end
    end

    sample = make_sample samp
    sample.save

    unless sample.errors.empty? && @errors.length == 0
      @errors = @errors + sample.errors.full_messages.collect { |m|
        samp[:copy][:name] + ": " + m
      }
      raise ActiveRecord::Rollback
    end

    @samples << sample
    sample

  end

  def save_new

    @errors = []
    @samples = []

    begin
      Sample.transaction do
        params[:new_samples].each do |samp|
          save_new_aux samp
        end
      end
    rescue Exception => e
      render json: { errors: [ e.to_s, e.backtrace[0..5].join(", ") ] }
    else
      if @errors.length > 0 
        render json: { errors: @errors }
      else
        render json: { samples: @samples }
      end
    end

  end

end
