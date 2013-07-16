class ChangeJobLinkInLog < ActiveRecord::Migration

  def change
    change_table :logs do |t|
      t.rename :job, :job_id
    end
  end

end
