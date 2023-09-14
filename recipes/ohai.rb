# This recipe just outputs the results of the ohai hardening plugin
# its basically just a sanity check for test-kitchen
puts "
********************************************************************************
********************************************************************************
OHAI PLUGIN CHECK

node['hardening']
#{Chef::JSONCompat.to_json_pretty(node['hardening'])}

********************************************************************************
********************************************************************************
"
