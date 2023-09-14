#
# This plugin returns infromation about the active directory domain
#

Ohai.plugin(:Bw10001) do
  provides 'hardening/BW1-00-01'
  depends 'hardening'

  def on_domain?(config)
    # When the machine is not on a domain, the entry for `Workstation Domain DNS Name` is
    # not present.  Since there are no other /DNS/ entries in the config, this is a safe search
    config.include?('DNS')
  end

  def config_get_value(config, pattern)
    # Iterate the configuration for key value pairs
    # Skip lines that don't match the search pattern.
    # Lines are space delimited, but keys have spaces in them.
    # Grabbing the string after the last space group
    config.lines do |line|
      next unless line =~ pattern

      return line.strip.split(/ +/)[-1] # Splits the line on spaces, and return the last element
    end
  end

  collect_data(:default) do
    bw1_00_01 Mash.new

    # Get the system configuration once, so that we can pass it around to different
    # methods for analysis and data extraction
    # NOTE: This command returns an error over a remote connection (kitchen), but will run successfully
    #        from the local system.  There is no anticipated problem running it in prod.
    system_config = shell_out('net config workstation').run_command.stdout

    bw1_00_01[:domain_member] = on_domain?(system_config)

    # if the system is on a domain, get the domain name and dns domain
    if bw1_00_01[:domain_member]
      bw1_00_01[:domain]        = config_get_value(system_config, /^Workstation domain/)
      bw1_00_01[:dns_domain]    = config_get_value(system_config, /^Workstation Domain DNS Name/)
    else # Otherwise, get the system's workgroup
      bw1_00_01[:workgroup]     = config_get_value(system_config, /^Workstation domain/)
    end

    hardening['BW1-00-01'] = bw1_00_01
  end
end
