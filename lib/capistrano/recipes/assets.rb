module CapistranoRecipes
  module Assets
    def self.load_into(configuration)
      configuration.load('deploy/assets')
    end
  end
end