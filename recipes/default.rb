# I'm generally not fond of using file searches to include recipes.
# Given the number of recipes, this just looks cluttered when we
# include them all individually.
node.run_state['errors'] = {}

# Run BW recipes on Windows.  Linux hardening is depricated in favor of Golden Images
recipe_header = case node['platform']
                when 'windows'
                  'BW'
                when 'suse', 'redhat', 'ubuntu'
                  node.run_state['errors']['general_error'] = "This cookbook is deprecated!\nPlease use the Golden Images provided by the MultiCloud network secuity team, or the Ansible playbooks that they have developed.\nSee https://github.tools.sap/mc-network-security/Golden-Images for details."
                  nil
                else
                  node.run_state['errors']['general_error'] = "The #{node['platform']} OS is not supported by this cookbook."
                  nil
                end

# get all the recipes in the folder
all_recipes = ::Dir.entries(::File.dirname(__FILE__))

# Filter for only the ones that match BW or BL
platform_recipes = recipe_header ? all_recipes.select { |recipe| recipe.include?(recipe_header) } : []

# Remove the `.rb.` and include each recipe
platform_recipes.each do |plat_recipe|
  include_recipe_name = plat_recipe.split('.')[0] # remove the file ext
  include_recipe "::#{include_recipe_name}" unless node[cookbook_name]['exclusions'].include?(include_recipe_name)
end

Chef.event_handler do
  on :run_completed do
    HandlerFailureCollector::Helper.new.raise_all_warnings_as_errors(
      Chef.run_context.node.run_state
    )
  end unless ENV['TEST_KITCHEN']
end
