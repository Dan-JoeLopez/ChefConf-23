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
end
