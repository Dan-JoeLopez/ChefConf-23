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
      # and then selects only the names.
      # NOTE: not using shellout here because its got a bug where PS commands run twice, and output is doubled
      return '' unless kernel['os_info']['caption'].include?('Server') # "features" are not available on non-server OSes, so skip this
      `powershell -command "Get-WindowsFeature | Where-Object {$_. installstate -eq 'installed' -and $_.featuretype -eq 'Role'} \| select name \| ft -HideTableHeaders"`
    end

    def describe_offence(check_result)
      if BaseLineHelper.sole_roles(check_result)
        "The role(s) #{check_result.to_s} MUST not be installed with any other roles!"
      elsif BaseLineHelper.ad_special_roles(check_result) && BaseLineHelper.ad_vulnerability_roles(BaseLineHelper.ad_special_roles(check_result))
        "The AD role(s) #{check_result.to_s} MUST not be installed with #{BaseLineHelper.ad_vulnerability_roles(BaseLineHelper.ad_special_roles(check_result))}"
      end
    end

    def roles_to_keep(check_result, installed_roles)
      if BaseLineHelper.sole_roles(check_result)
        check_result[0]
      elsif BaseLineHelper.ad_special_roles(check_result) && BaseLineHelper.ad_vulnerability_roles(BaseLineHelper.ad_special_roles(check_result))
        BaseLineHelper.ad_special_roles(check_result)
      end
    end

    def roles_to_remove(check_result, installed_roles)
      if BaseLineHelper.sole_roles(check_result)
        installed_roles - check_result[0]
      elsif BaseLineHelper.ad_special_roles(check_result) && BaseLineHelper.ad_vulnerability_roles(BaseLineHelper.ad_special_roles(check_result))
        installed_roles - BaseLineHelper.ad_vulnerability_roles(BaseLineHelper.ad_special_roles(check_result))
      end
    end
    
  collect_data(:windows) do
    bw1_00_02 Mash.new

    installed_roles = powershell_get_roles
    non_compliance_check = BaseLineHelper.1_00_02_non_compliance(installed_roles)
    bw1_00_02[:offenses]        =  non_compliance_check? describe_offence(non_compliance_check) : '' # String explaining how the policy is being violated
    bw1_00_02[:desired_roles]   =  non_compliance_check? roles_to_keep(non_compliance_check, installed_roles) : [] # Array of which special roles are to remain installed
    bw1_00_02[:undesired_roles] =  non_compliance_check? roles_to_remove(non_compliance_check, installed_roles) : [] # Array of roles/features that are to be removed
    bw1_00_02[:compliant]       =  non_compliance_check == false # bool check to see if the system is compliant with the policy

    hardening['BW1-00-02'] = bw1_00_02
  end
end
