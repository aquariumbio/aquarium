# typed: false
# frozen_string_literal: true

# @api krill
class Upload < ApplicationRecord

  attr_accessible :job_id, :upload
  has_attached_file :upload
  do_not_validate_attachment_file_type :upload

  belongs_to :job
  has_many :data_associations
  has_one :upload

  def name=(n)
    self.upload_file_name = n
  end

  def name
    upload_file_name
  end

  def size
    upload_file_size
  end

  def url
    upload.expiring_url(10)
  end

  def expiring_url
    upload.expiring_url(10)
  end

  delegate :path, to: :upload

  def export
    attributes
  end

end
