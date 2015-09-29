class FolderContent < ActiveRecord::Base

  attr_accessible :folder_id, :sample_id

  belongs_to :folder
  belongs_to :sample

end
