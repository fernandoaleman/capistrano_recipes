module CapistranoRecipes
  module RailsAssets
    def self.load_into(configuration)
      configuration.load('deploy/assets')
    end
  end
end