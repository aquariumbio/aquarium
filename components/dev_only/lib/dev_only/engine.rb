module DevOnly
  class Engine < ::Rails::Engine
    isolate_namespace DevOnly

    initializer "dev_only.assets.precompile" do |app|
      app.config.assets.precompile += %w( dev_only/application.js dev_only/application.css )
    end
  end
end
