# This resource manages the default windows users (Administrator
# and Guest), with the ability to rename and disable them.
#
# FC048 is ignored: Using backticks over shell_out on windows
# because of duplicate command execution with shell_out for powershell commands
#

resource_name :default_win_user
provides :default_win_user

property :user_name, String, name_property: true
property :active, String
property :new_name, String

load_current_value do |desired|
  # If the named user is not present, set the resource as up-to-date
  # Also log the fact that the user is not there,
  # incase anyone is trying to use this resource for user creation...

  # Concatenate both keys and force them to a string, ensuring nil values won't throw an error
  default_users = "#{node['hardening'][desired.recipe_name]['admin_present']}#{node['hardening'][desired.recipe_name]['guest_present']}"
  user_present = default_users.include?(desired.user_name)
  if !user_present
    puts "#{desired.recipe_name}\n\tThe user #{desired.user_name} is not present, skipping execution..."
    puts "#{desired.recipe_name}\n\tThe `default_win_user` resource cannot activate non-present users, please use the built-in `User` resource instead." if desired.active == 'Yes'

    # Mark all properties as up-to-date
    user_name desired.user_name if desired.user_name
    active    desired.active    if desired.active
    new_name  desired.new_name  if desired.new_name
  else
    # Otherwise, we need to collect the current state for the user

    # Have to use net commands to get user info, because win 2012
    user_info = ::BaseLineHelper.shellout_lines "net user #{desired.user_name}"

    user_info_hash = user_info.map do |info_line|
      next if info_line.empty?

      key_value = info_line.split(/ {2,}/) # splitting on 2+ spaces so that single spaced key names don't get split
      key_value if key_value.size == 2
    end.compact.to_h
    active user_info_hash['Account active']

    # And set the desired new name to the existing name
    new_name desired.user_name
  end
end

action :manage do
  converge_if_changed :active do
    `net user #{new_resource.user_name} /ACTIVE:#{new_resource.active}"` # ignore: ~FC048
  end

  converge_if_changed :new_name do
    `wmic useraccount where name='#{new_resource.user_name}' rename #{new_resource.new_name}` # ignore: ~FC048
  end
end
