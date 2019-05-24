# frozen_string_literal: true

class CollectionsDatatable < Datatable

  private

  def data

    rows.map do |c|

      [
        link_to(c.id, c),
        c.location,
        link_to(c.object_type.name, c.object_type),
        @view.render(partial: '/handlers/collection_matrix', locals: { m: c.datum[:matrix], small: true, highlight: params[:sample_id].to_i }),
        c.created_at.to_formatted_s(:short),
        c.updated_at.to_formatted_s(:short),
        link_to(@view.item_path(c, sample_id: params[:sample_id]), method: :delete, data: {
                  confirm: 'Are you sure you want to delete this collection?'
                }) do
          "<i class='icon-remove'></i>".html_safe
        end
      ]

    end

  end

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows
    cols = Collection.includes(:user).containing Sample.find(params[:sample_id])
    if !params[:show_deleted]
      cols.reject(&:deleted?)
    else
      cols
    end
  end

  # TODO: remove? this doesn't appear to be used
  def sort_column
    columns = %w[id matrix id created_at updated_at] # possibly redefine in children classes
    columns[params[:iSortCol_0].to_i]
  end

end
