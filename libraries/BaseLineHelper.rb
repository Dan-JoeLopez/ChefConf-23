module ::BaseLineHelper
  def self.match_lines(target_file, filter)
    # Guard to avoid return nil
    return '' unless ::File.exist?(target_file)
    # Open /etc/pam.d/password-auth file searching for patterns
    array = ::File.readlines(target_file).select { |line| line =~ /^(?!#)#{filter}$/ }
    array.empty? ? '' : array.join
  end

  def self.nfs_platform_svc_name
    svc_name = 'nfs'
    svc_name += '-server' if ::Chef.node['platform_family'] == 'rhel' && ::Chef.node['platform_version'] =~ /7.\d/ # for RHEL 7.x
    svc_name += '-server' if ::Chef.node['platform'] == 'ubuntu'                                                   # for ubuntu any«
    svc_name += 'server' if ::Chef.node['platform_family'] == 'suse' && ::Chef.node['platform_version'] =~ /1(2|5).*/ # for SUSE
    svc_name
  end

  def self.shellout_lines(command)
    Mixlib::ShellOut.new(command).run_command.stdout.strip.split("\n").map(&:strip)
  end

  def self.pam_pkg_deps
    if ::Chef.node['platform_family'] == 'rhel' && ::Chef.node['platform_version'] =~ /7.\d/
      %w(pam.i686 nss-pam-ldapd.i686 nss-pam-ldapd.x86_64 pam-devel.i686 pam-devel pam_mount)
    elsif ::Chef.node['platform_family'] == 'suse'
      %w(pam pam-config pam-32bit pam_ldap pam_ldap-32bit pam-modules pam-modules-32bit pam_mount pam_mount-32bit)
    else
      %w(pam pam-32bit pam-config pam-devel pam-devel-32bit pam-modules pam-modules-32bit pam_mount)
    end
  end
 
  def self.parse_roles(cmd_out)
    # This method gets the list of roles from powershell, and makes them into an array over which we can easily itterate
    # its a simple comamnd, but putting it here allows us to more clearly define what we are doing
    # NOTE: we could also overload the String class to include a method to do this (String.to_a)...
    cmd_out.strip.split("\n")
  end

  # These modules union the passed role array with the list of various special roles, returning an array of matches
  # between the two, or an empty array if there are none
  def self.sole_roles(roles)
    roles & %w(Hyper-V Remote-Desktop-Services Network-Policy-and-Access-Services)
  end

  def self.ad_special_roles(roles)
    roles & %w(AD-Certificate ADFS-Federation ADLDS ADRMS)
  end

  def self.ad_vulnerability_roles(roles)
    roles & %w(AD-Domain-Services DNS)
  end

  def self.1_00_02_non_compliance(roles)
    # This role is going to check if the role list is compliant with the policy
    # returns the role(s) triggering the non-compliance

    # Parse the list of roles
    roles = parse_roles.(roles)

    # if there are 0 or 1 role, the server is compliant
    return false unless roles.size > 1
    
    # Since there are 2 "legs" of the policy we'll check both
    # ... starting with standalone roles
    unique_roles = BaseLineHelper.sole_roles(roles)
    return unique_roles unless unique_roles.empty? # returns an array of all sole roles installed
    
    # ... and now check role combinations
    special_roles = BaseLineHelper.ad_special_roles(roles)
    unless special_roles.empty?
      ad_vulnerabilies = BaseLineHelper.ad_vulnerability_roles(special_roles)
      return ad_vulnerabilies unless ad_vulnerabilies.empty?
    end

    # More than one role are installed, but none of them are "specail"
    false # returns false for easy bool checking (if ::BaseLineHelper.1_00_02_non_compliance(role_list)...)
  end
end
