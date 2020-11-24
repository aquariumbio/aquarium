# frozen_string_literal: true

# application_record base
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
