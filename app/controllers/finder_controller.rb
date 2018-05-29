# frozen_string_literal: true

class FinderController < ApplicationController

  before_filter :signed_in_user

  def projects
    render json: (Sample.all.collect { |s| { id: 0, name: s.project } }).uniq.sort { |a, b| a[:name] <=> b[:name] }
  end

  def types

    spec = JSON.parse(params[:spec], symbolize_names: true)

    if params[:filter] != ''

      # Determine if filter an object type
      ot = ObjectType.find_by_name(params[:filter])
      samp = if ot && ot.sample_type
               ot.sample_type.name
             else
               params[:filter]
             end

    end

    if samp != ''
      types = '(' + (samp.split('|').collect { |t| "sample_types.name = '#{t}'" }).join(' OR ') + ')'
      render json: (Sample.includes('sample_type').where("project = ? and #{types}", spec[:project]).collect { |s| { id: s.sample_type.id, name: s.sample_type.name } }).uniq.sort { |a, b| a[:name] <=> b[:name] }
    else
      render json: (Sample.includes('sample_type').where('project = ?', spec[:project]).collect { |s| { id: s.sample_type.id, name: s.sample_type.name } }).uniq.sort { |a, b| a[:name] <=> b[:name] }
    end

  end

  def samples
    spec = JSON.parse(params[:spec], symbolize_names: true)
    s = Sample.joins(:sample_type).where(project: spec[:project], sample_types: { name: spec[:type] })
    render json: (s.collect { |s| { id: s.id, name: s.name } }).uniq.sort { |a, b| a[:name] <=> b[:name] }
  end

  def containers
    spec = JSON.parse(params[:spec], symbolize_names: true)
    logger.info 'spec = ' + spec.to_json
    filter = ObjectType.find_by_name(params[:filter])

    con = if filter
            (ObjectType
              .joins(items: :sample)
              .where(name: filter.name, samples: { project: spec[:project], name: spec[:sample] })
              .collect { |o| { id: o.id, name: o.name } })
          else
            (ObjectType
              .joins(items: :sample)
              .where(samples: { project: spec[:project], name: spec[:sample] })
              .collect { |o| { id: o.id, name: o.name } })
          end

    col = ObjectType.where(handler: 'collection')

    render json: (con + col).uniq.sort { |a, b| a[:name] <=> b[:name] }

  end

  def items

    spec = JSON.parse(params[:spec], symbolize_names: true)

    ot = ObjectType.where(name: spec[:container])[0]

    if ot.handler == 'collection'

      sample = Sample.find_by_name(spec[:sample])

      render json: (Collection.joins(:object_type)
        .where(object_types: { id: ot.id })
        .reject(&:deleted?)
        .select { |c| c.matrix && c.matrix.flatten.index(sample.id) })
        .collect { |i| { id: i.id, name: i.id } }

    else

      render json: (
        Item.joins(:sample, :object_type)
        .where(samples: { project: spec[:project], name: spec[:sample] }, object_types: { name: spec[:container] })
        .reject(&:deleted?)
        .collect { |i| { id: i.id, name: i.id } })

    end

  end

  def sample_info
    spec = JSON.parse(params[:spec], symbolize_names: true)
    s = Sample.find(spec[:sample_id])
    props = { id: s.id, name: s.name, created_at: s.created_at, updated_at: s.updated_at, description: s.description }
    (1..8).each do |i|
      prop = s.sample_type["field#{i}name"]
      props[s.sample_type["field#{i}name"].to_sym] = s["field#{i}"] if prop != '' && !prop.nil?
    end
    render json: props
  end

  def type

    t = params[:type].split '|'

    if SampleType.find_by_name(t.first)
      render json: { type: 'Samples' }
    else
      if ObjectType.find_by_name(t.first)
        render json: { type: 'Items' }
      else
        render json: { type: 'Unknown' }
      end
    end
  end

end
