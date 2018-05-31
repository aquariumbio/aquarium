

namespace :field do

  desc 'Making fields agnostic about their parents'

  task agnostic: :environment do
    FieldType.update_all parent_class: 'SampleType'
    FieldValue.update_all parent_class: 'Sample'
  end

end
