class ItemsDatatable < Datatable

  private

  def data

    rows.map do |i|
      [link_to(i.id, i),
       i.location,
       "<span class='json'>#{i.data}</span>",
       i.created_at.to_formatted_s(:short),
       i.updated_at.to_formatted_s(:short),
       link_to(@view.item_path(i, sample_id: params[:sample_id]), method: :delete, data: {
                 confirm: 'Are you sure you want to delete this item?'
               }) do
         "<i class='icon-remove'></i>".html_safe
       end]
    end

  end

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows

    items = Item.page(page).per_page(per_page)
    @view.logger.info "sd = #{params[:deleted]}"

    items = if params[:show_deleted]
              items.where('sample_id = ? and object_type_id = ?', params[:sample_id], params[:object_type_id])
            else
              items.where("sample_id = ? and object_type_id = ? and location != 'deleted'", params[:sample_id], params[:object_type_id])
            end

    items

  end

  def sort_column
    columns = %w[id location data created_at updated_at]
  end

end
