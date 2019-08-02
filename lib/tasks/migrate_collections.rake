namespace :collections do

  desc 'Migrate Collections to 2.0'

  task migrate: :environment do

    part_type = ObjectType.find_by_name "__Part"
    orphan_type = ObjectType.find_by_name "Orphan"

    unless part_type

      part_type = ObjectType.new(
        name: "__Part",
        description: "Part of a collection",
        min: 0,
        max: 1,
        handler: "sample_container",
        safety: "No safety information",
        cleanup: "No cleanup information",
        data: "No data", vendor: "No vendor information",
        unit: "part",
        cost: 0.01,
        release_method: "return",
        release_description: "",
        image: "",
        prefix: ""
      )

      part_type.save
      raise "Could not create part type: #{part_type.errors.full_messages.join(',')}" unless part_type.errors.empty?

    end

    unless orphan_type

      orphan_type = ObjectType.new(
        name: "Orphan",
        description: "Part of a collection",
        min: 0,
        max: 1,
        handler: "part",
        safety: "No safety information",
        cleanup: "No cleanup information",
        data: "No data", vendor: "No vendor information",
        unit: "part",
        cost: 0.01,
        release_method: "return",
        release_description: "",
        image: "",
        prefix: ""
      )

      orphan_type.save

      raise "Could not create orphan type: #{part_type.errors.full_messages.join(',')}" unless orphan_type.errors.empty?

    end

    ctids = ObjectType.where(handler: 'collection').map(&:id)

    items = Item.where(object_type_id: ctids)

    n = 0
    orphans = 0
    msg = "Starting migration"
    items.each do |i|
      c = (i.becomes Collection)
      unless c.datum[:_migrated_]
        begin
          c.migrate
          # TODO: this is probably JSON::ParserError
        rescue Exception => e
          c.associate :migration_error, "Could not migrate this collecton. Setting object type to orphan"
          c.associate :migration_error_msg, "Error: #{e}"
          c.object_type_id = orphan_type.id
          c.save
          orphans += 1
        end
      end
      n += 1
      print((0...msg.length).collect { |i| "\b" }.join(''))
      p = sprintf("%.2f", 100.0 * n / items.length)
      msg = "#{p}\% complete. #{orphans} errors."
      print "\e[32m" + msg + "\e[0m"
    end

    orphan_ids = Item.where(object_type_id: orphan_type.id).map(&:id)
    if !orphan_ids.empty?
      puts "\nThe following collections were not migrated due to errors"
      puts orphan_ids.join(", ")
    end

  end

end
