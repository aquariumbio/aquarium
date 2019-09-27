# frozen_string_literal: true

class SearchController < ApplicationController

  before_filter :signed_in_user

  def search

    @autocomplete = Sample.all.collect(&:name).concat(ObjectType.all.collect(&:name))

    @query = params[:query] || ''

    @results = if params[:type] == 'sample'

                 (Sample.includes(items: %i[object_type sample]).select { |s| Regexp.new(params[:query]) =~ s.name }).collect(&:items).flatten.reject(&:deleted?)

               elsif params[:type] == 'objecttype'

                 ObjectType.all.select { |ot| Regexp.new(params[:query]) =~ ot.name }

               else

                 []

               end

  end

end
