class SearchController < ApplicationController

  before_filter :signed_in_user

  def search

    @autocomplete = (Sample.all.collect { |s| s.name }).concat(ObjectType.all.collect { |ot| ot.name })

    @query = params[:query] ? params[:query] : ""

    if params[:type] == 'sample'

      @results = ((Sample.includes(items: [:object_type, :sample]).select { |s| Regexp.new(params[:query]) =~ s.name }).collect { |s| s.items }).flatten.select { |i| !i.deleted? }

    elsif params[:type] == 'objecttype'

      @results = ObjectType.all.select { |ot| Regexp.new(params[:query]) =~ ot.name }

    else

      @results = []

    end

  end

end
