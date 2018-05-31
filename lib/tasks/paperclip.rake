

namespace :paperclip do

  desc 'Upgrade to S3'

  task var: :environment do
    Upload.all.each do |u|
      puts "#{u.id},#{u.upload.path}"
    end
  end

end
