class Folder < ActiveRecord::Base

  attr_accessible :name, :user_id, :parent_id

  def children
    Folder.where(parent_id: self.id).collect do |f|
      { id: f.id,
        name: f.name,
        children: f.children }
    end
  end

  def self.tree user
    folders = Folder.where(user_id: user.id, parent_id: nil)
    [
      { 
        id: -1,
        name: user.name,
        children: folders.collect do |f|
          { id: f.id,
            name: f.name,
            children: f.children }
        end
      }
    ]
  end

  def children
    Folder.where(parent_id: self.id)
  end

  def self.trash f
    f.children.each do |c|
      Folder.trash c
    end
    f.destroy
  end

end
