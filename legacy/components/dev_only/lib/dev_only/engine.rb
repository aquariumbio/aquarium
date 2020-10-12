module DevOnly
  class Engine < ::Rails::Engine
    isolate_namespace DevOnly
  end
end
