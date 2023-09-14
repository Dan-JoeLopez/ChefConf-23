# This plugin instanciates a new empty plugin
# The other plugins here will populate it with data

Ohai.plugin(:Hardening) do
  provides 'hardening'

  collect_data(:default) do
    hardening Mash.new
  end
end
