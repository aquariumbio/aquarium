class ItemsDatatable < Datatable

  private  

  def data
    rows.map do |i|
      [ link_to(i.id,i), i.location, i.data, i.created_at, i.updated_at ]
    end
  end

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows
    items = Item.page(page).per_page(per_page)
    @view.logger.info "sd = #{params[:deleted]}"
    if params[:show_deleted]
      items = items.where("sample_id = ? and object_type_id = ?", params[:sample_id], params[:object_type_id])
    else
      items = items.where("sample_id = ? and object_type_id = ? and location != 'deleted'", params[:sample_id], params[:object_type_id])
    end
    items    
  end

  def sort_column
    columns = %w[id location data created_at updated_at ]
  end

end
