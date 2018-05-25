class Datatable

  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: rows.count,
      iTotalDisplayRecords: rows.class == ActiveRecord::Relation ? rows.total_entries : rows.length,
      aaData: data
    }
  end

  private

  def data
    [] # redefine this is child class
  end

  def rows
    [] # redefine this is child class
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def sort_column
    columns = Array.new(20, "id") # redefine in child class
    columns[params[:iSortCol_0].to_i]
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
