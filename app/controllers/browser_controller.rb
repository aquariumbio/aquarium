# frozen_string_literal: true

class BrowserController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def browser
    @conflicts = Wizard.conflicts
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end
  end

  def all

    sts = SampleType.includes(:samples).all
    result = {}

    sts.each do |st|
      result[st.name] = st.samples.collect do |s|
        "#{s.id}: #{s.name}"
      end.reverse
    end

    render json: result

  end

  def recent_samples
    user = User.find_by(id: params[:id]) if params[:id]
    if !user
      render json: Sample
        .last(25)
        .reverse
        .to_json(only: %i[name id user_id data sample_type_id])
    else
      render json: Sample
        .where(user_id: user.id)
        .last(25)
        .reverse
        .to_json(only: %i[name id user_id data sample_type_id])
    end
  end

  def projects
    user = User.find_by(id: params[:uid]) if params[:uid]
    if !user
      render json: {
        projects: Sample.uniq.pluck(:project)
                        .sort
                        .collect { |p| { name: p, selected: false, sample_type_ids: Sample.where(project: p).pluck(:sample_type_id).uniq } }
      }
    else
      render json: {
        projects: Sample.where(user_id: user.id)
                        .uniq
                        .pluck(:project)
                        .sort
                        .collect { |p| { name: p, selected: false, sample_type_ids: Sample.where(project: p).pluck(:sample_type_id).uniq } }
      }
    end
  end

  def samples_for_tree
    render json: Sample
      .where(project: params[:project], sample_type_id: params[:sample_type_id].to_i)
      .reverse
      .to_json(only: %i[name id user_id data])
  end

  def gory_details_of_samples_for_tree
    render json: Sample
      .includes(field_values: :child_sample, sample_type: { field_types: { allowable_field_types: :sample_type } })
      .where(project: params[:project], sample_type_id: params[:sample_type_id].to_i)
      .reverse
      .to_json(include: {
                 field_values: { include: :child_sample }
               }, except: %i[field1 field2 field3 field4 field5 field6 field7 field8])
  end

  def subsamples
    render json: Sample.find(params[:id]).properties
  end

  def sample_name_from_identifier(str)
    parts = str.split(': ')
    if parts.empty?
      ''
    elsif parts.length == 1
      parts[0]
    else
      parts[1..-1].join(': ')
    end
  end

  def create_samples

    @errors = []
    @samples = []

    begin
      Sample.transaction do
        params[:samples].each do |samp|
          sample = Sample.creator(samp, current_user)
          if sample.errors.empty?
            @samples << sample
          else
            @errors << sample.errors.full_messages.join(', ')
            raise ActiveRecord::Rollback
          end
        end
      end
    rescue StandardError => e
      render json: { errors: [e.to_s, e.backtrace[0..5].join(', ')] }
    else
      if !@errors.empty?
        render json: { errors: @errors }
      else
        render json: { samples: @samples }
      end
    end

  end

  def annotate
    s = Sample.find(params[:id])
    begin
      data = JSON.parse(s.data)
    rescue JSON::ParserError
      data = {}
    end
    data[:note] = (params[:note] == '_EMPTY_' ? '' : params[:note])
    s.data = data.to_json
    s.save
    render json: s
  end

  def items
    sample = Sample.find(params[:id])
    item_list = Item.with_sample(sample: sample)
    containers = ObjectType.container_types(sample_type: sample.sample_type)
    render json: { items: item_list.as_json(include: [:locator, :object_type]),
                   containers: containers.as_json(only: %i[name id]) }
  end

  def collections
    sample = Sample.find(params[:sample_id])
    collections = Collection.containing(sample)
    containers = collections.collect(&:object_type).uniq
    render json: { collections: collections.as_json(include: :object_type, methods: :matrix),
                   containers: containers.as_json(only: %i[name id]) }
  end

  def search
    # TODO: move search code to Sample and Item/Collection
    samples = Sample.where('name like ? or id = ?', "%#{params[:query]}%", params[:query].to_i)

    puts 'SAMPLE COUNT: ' + samples.length.to_s
    if params[:item_id].present?
      sample_list = Sample.none
      item = Item.find_by(id: params[:item_id].to_i)
      if item
        sample_id_list = if item.collection?
                           collection = item.becomes Collection
                           collection.parts.collect(&:sample_id)
                         else
                           [item.sample_id]
                         end

        sample_id_list.uniq.each do |sample_id|
          sample_list = sample_list.or(samples.where(id: sample_id))
        end
      end
      samples = sample_list
    end

    puts 'SAMPLE COUNT: ' + samples.length.to_s
    if params[:user_filter]
      user = User.find_by(login: params[:user])
      samples = samples.owned_by(user: user) if user
    end
    puts 'SAMPLE COUNT: ' + samples.length.to_s
    if params[:project_filter]
      samples = samples.for_project(project: params[:project]) if params[:project].present?
    end
    puts 'SAMPLE COUNT: ' + samples.length.to_s
    if params[:sample_type].present?
      sample_type = SampleType.find_by(name: params[:sample_type])
      samples = if sample_type
                  samples.with_sample_type(sample_type: sample_type)
                else
                  []
                end
    end
    puts 'SAMPLE COUNT: ' + samples.length.to_s

    sample_list = if samples.empty?
                    []
                  else
                    samples.offset(params[:page] * 30)
                           .last(30)
                           .reverse
                           .as_json(only: %i[name id user_id data sample_type_id])
                  end

    render json: { samples: sample_list, count: samples.count }
  end

  def samples
    samples = if params[:user_id]
                Sample.where(sample_type_id: params[:id], user_id: params[:user_id])
              else
                Sample.where(sample_type_id: params[:id])
              end

    render json: samples.offset(params[:offset]).last(30).reverse
                        .to_json(only: %i[name id user_id data created_at])
  end

  def delete_item
    item = Item.find(params[:item_id])
    item.mark_as_deleted
    item.reload
    render json: { location: item.location }
  end

  def restore_item
    item = Item.find(params[:item_id])
    item.store
    if item.errors.empty?
      render json: { location: item.location }
    else
      render json: { location: item.location, errors: item.errors.full_messages }
    end
  end

  def save_data_association
    parent = DataAssociation.find_parent(params[:parent_class], params[:id])
    parent.associate(params[:key], params[:value])
    da = parent.get_association params[:key]
    Rails.logger.info "parent = #{parent.inspect}"
    Rails.logger.info "da = #{da.inspect}"
    render json: { data_association: da, parent: parent, errors: parent.errors.full_messages }
  end

end
