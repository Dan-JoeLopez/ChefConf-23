# The related recipe has no actions, only logging

# Since the policy cannot be applied automatically, it is not possible to _test_
# for it.

# We can't _enforce_ these Role constraints; because that coule mean removing
# productive Roles from productive servers, nor could we know _which_ roles
# could be removed...

require_realative '../../libraries/BaseLineHelper'

installed_roles = command('powershell -command "Get-WindowsFeature | Where-Object {$_. installstate -eq \'installed\' -and $_.featuretype -eq \'Role\'} \| select name \| ft -HideTableHeaders"').stdout

rasie 'BW 1-00-02 is not compliant!' if BaseLineHelper.1_00_02_non_compliance(installed_roles)
