#
# This plugin reads the installed features on the node,
# and checks them against the security policy.
#

Ohai.plugin(:Bw10002) do
  provides 'hardening/BW-1-00-02'
  depends 'hardening'
  depends 'kernel'

  def powershell_get_roles
    # This powershell command gets the installed roles (see the `where-object` part)
    # and then selects only the names.  It gets split on newlines to create a feature array
    # NOTE: not using shellout here because its got a bug where PS commands run twice, and output is doubled
    return [] unless kernel['os_info']['caption'].include?('Server') # "features" are not available on non-server OSes, so skip this
    `powershell -command "Get-WindowsFeature | Where-Object {$_. installstate -eq 'installed' -and $_.featuretype -eq 'Role'} \| select name \| ft -HideTableHeaders"`.strip.split("\n")
  end

  def analyze_conflicts(installed_roles)
    # When multiple roles are installed (there are no rules against servers with only one role)
    if installed_roles.size > 1

      # The following roles must be installed ALONE
      singleton_roles = %w(Hyper-V Remote-Desktop-Services Network-Policy-and-Access-Services) # NPAS - Need to check on the name, its for Windows 2012
      offences = (installed_roles & singleton_roles) # Use array intersection to find matches
      return offences unless offences.empty?

      # The following roles cannot be installed with DNS or other AD roles
      ad_singleton_roles = %w(AD-Certificate ADFS-Federation ADLDS ADRMS)
      unless (installed_roles & ad_singleton_roles).empty? # Use array intersection to find matches
        vulnerable_companions = ad_singleton_roles + %w(AD-Domain-Services DNS) # Can't be enabled together either, hence the `+`
        offences = (installed_roles & vulnerable_companions)
        return [(installed_roles & ad_singleton_roles), offences] unless offences.empty?
      end
    end
    nil
  end

  collect_data(:windows) do
    bw1_00_02 Mash.new

    bw1_00_02[:roles]     = powershell_get_roles
    bw1_00_02[:offendors] = analyze_conflicts(bw1_00_02[:roles])
    bw1_00_02[:compliant] = bw1_00_02[:offendors].nil?

    hardening['BW1-00-02'] = bw1_00_02
  end
end
