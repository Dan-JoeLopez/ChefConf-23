#
# Cookbook:: litc-base-line-hardening
# Recipe:: BW1-00-02
# Description::
#   1.00 General Requirements
#   1.00.02 Separation of duties and purposes
# Copyright:: 2020, SAP DevOps CoE
#
# All rights reserved - Do Not Redistribute
#

bw1_00_02 'Ensure overlapping duties and purpose compliance' do
  policy_state node['hardening'][recipe_name]
  action :enforce
end

# This policy is not enforcable by automation, we we can issue some checks and
# logging about it for transparency.

# #!#!#!#!#!#!#!#!#!#!#!# This recipe takes NO actions #!#!#!#!#!#!#!#!#!#!#!#!#

# If the node has a conflicting role configuration, we log as warn, otherwise it should be info
log_level = !node['hardening'][recipe_name]['offendors'] ? :info : :warn

# The message also changes based on the status
log_message = if log_level == :info
                "#{recipe_name}\n\tRoles separated, the node is compliant."
              else
                "#{recipe_name}\n\tOffences detected:\t\t#{node['hardening'][recipe_name]['offendors']}."
              end

log "#{recipe_name} Status" do
  message log_message
  level log_level
end

node.run_state['errors'][recipe_name] = log_message if log_level == :warn
