class SearchController < ApplicationController

  before_filter :signed_in_user

  def search

    # set up auto complete data here?

    @query = params[:query] ? params[:query] : ""

    if params[:type] == 'sample'

      @results = ((Sample.includes(items: [:object_type,:sample]).select { |s| Regexp.new(params[:query]) =~ s.name }).collect { |s| s.items }).flatten.select { |i| i.location != 'deleted' }

    elsif params[:type] == 'objecttype'

    else
      @results = []
    end

  end

end
