#
# Cookbook:: litc-base-line-hardening
# Recipe:: BW1-00-01
# Description::
#   1.00 General Requirements
#   1.00.01 Connect the system to a suitable AD
# Copyright:: 2020, SAP DevOps CoE
#
# All rights reserved - Do Not Redistribute
#

# This policy is not enforcable by automation, we we can issue some checks and
# logging about it for transparency.

# #!#!#!#!#!#!#!#!#!#!#!# This recipe takes NO actions #!#!#!#!#!#!#!#!#!#!#!#!#

# If the node is a domain member, we log as info, otherwise it should be a warning
log_level = node['hardening'][recipe_name]['domain_member'] ? :info : :warn

# The message also changes based on the status
log_message = if log_level == :info
                "#{recipe_name}\n\tDomain membership:\t\t#{node['hardening'][recipe_name]['domain']}."
              else
                "#{recipe_name}\n\tNo domain membership detected!"
              end

log "#{recipe_name} Status" do
  message log_message
  level log_level
end

node.run_state['errors'][recipe_name] = log_message if log_level == :warn
