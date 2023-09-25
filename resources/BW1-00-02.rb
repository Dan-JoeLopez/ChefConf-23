# This resource manges the installed roles to ensure that roles do not
# violate the "Separation of duties and purposes" rule
#

# bw1_00_02 'Ensure overlapping duties and purpose compliance' do
#   policy_state node['hardening']['BW1-00-02']
#   action: <enforce|report>
# end

resource_name :bw1_00_02
provides :bw1_00_02

property :policy_state, Hash, name_property: false

load_current_value do |desired|
    policy_state desired.policy_state if node['hardening']['BW1-00-02']['compliant']
end

action :enforce do
  converge_if_changed :policy_state do

    node['hardening']['BW1-00-02']['undesired_roles'].each do |undesired_role|
      windows_feature undesired_role do
        action :remove
      end
    end
  end
end

action :report do
  converge_if_changed :policy_state do
    Chef::Log.error node['hardening']['BW1-00-02']['offenses']
  end
end
