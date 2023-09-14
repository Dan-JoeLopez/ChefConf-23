# litc-base-line-hardening

This cookbook implements the SAP Security Baseline hardening guidelines for Windows.

Please refer to the [core guidelines](https://wiki.wdf.sap.corp/wiki/display/itsec/Operating+System+Hardening+Procedure?src=sidebar)
as well as the [Windows](https://wiki.wdf.sap.corp/wiki/display/itsec/Windows+Server+Hardening+Procedure?src=sidebar) specific policies.

This cookbook DOES NOT implement ANY customer specific logic.  All custom functionality
must be implemented in a wrapper cookbook.

**NOTE** As of version 3.0, this cookbook no longer supports Linux.  Please use the Golden Images provided by the
MultiCloud network secuity team, or the Ansible playbooks that they have developed.
See [Golden-Images](https://github.tools.sap/mc-network-security/Golden-Images) for details.

## Dependencies
This cookbook has no external dependecies.

## Supported OS
* Windows Server
  * 2012
  * 2012 R2
  * 2016
  * 2019
* Windows Client
  * 10

## Information

This cookbook implements the baseline security standards set forth by the SAP Security team.  Landscape or
team specific **customizations are not** implimented.  See below for details on excluding enforcement of policies.

In addition to enforcing policies, the cookbook will collect data with OHAI, and log information and warnings
about the compliance status of the system. 

The polices that have been implimented are only accurate at the time of this writing.  The SAP Security team
may change the guidlines at any time without warning or notification.  It is the server owner's responsibility
to ensure the security of their system.

## Usage
### Attributes

|                      Key                     |           Type            |                              Description                               | Default |
| -------------------------------------------- | ------------------------- | ---------------------------------------------------------------------- | ------- |
| `['litc-base-line-hardening']['production']` | `TrueClass`, `FalseClass` | When `true`, skips execution of potentially destructive changes.       |  `true` |
| `['litc-base-line-hardening']['exclusions']` |       `StringArray`       | Fill this string array with policies that you want to remain insecure. |   `[]`  |

### Un-Enforceable policies

Certain policies are, by their nature, not enforcable.  Often because the availability of resources in
different network locations vaires, we cannot predict the availability of AD domains, software repositories, etc.

Wherever possible, information about the policies complinace will be logged.
* BW 1.00.01 Connect the system to a suitable AD
  * No resonable way to enforce the domain join. Non-compliance logs a Warning.
* BW 1.00.02 Separation of duties and purposes
  * We cannot resonably _remove_ server roles that are potentially serving production use-cases.  Offences log a Warning.
* BW 1.10.01 Minimal number of administrative accounts
  * The Security threshold is 8, however removing active users from the admin group could affect
  production, support and maintainence activities. Non-Compliance logs a Warning.
* BW 1.10.02 Service accounts with administrative privileges
  * As above, removing admin accounts could have a negative impact. Non-Compliance logs a Warning.
* BW 1.40.01  Install and configure anti-virus software on the server
  * Given the unknown different variations of software repositories, we can't assume to install a specific AV software.
  * We can check that one _is_ installed, and log a Waarning if it isn't.
* BW 1.50.01 Implement appropriate patch management
  * While we cannot force patching as this could generate a restart of a critical server, we'll log if the
  latest updates are older than a week. 

### Destructive Policies

* BW 1.10.03 Default OS accounts
  * This recipe **WILL RENAME** the `Administrator` and `Guest` accounts.
  * Thie behavior is configurable by setting the `production` attribute.
* BW 1.60.01 Configure secure permissions on network shares
  * This will **DISABLE** open shares (ones with `Everyone` access).
  * Thie behavior is configurable by setting the `production` attribute.
  * Additional user/group access needs to be autdited by a person with knowledge of the system requirements.

## Contributing

1. Fork the repository on Github
1. Write your test
1. Document your proposed change
1. Write your change
1. Test your change
1. Lint the cookbook
1. Submit a Pull Request using Github, and request a code review

## License and Authors

### Authors

* [Juan Martinez](Juan.Martinez@sap.com)
* [Rosen Rusev](Rosen.Rusev@sap.com)
* [Dan-Joe Loepz](Dan-Joe.Loepz@sap.com)

### License

For SAP Internal Use ONLY, not licensed for external contribution or
distribution.

## Support

If you need help with this cookbook, please raise an issue in Jira on project [ADC (Automation DevOps CoE)](https://sapjira.wdf.sap.corp/secure/CreateIssue!default.jspa),
or raise an [issue on git](https://github.wdf.sap.corp/LIT-DEVOPS/litc-example/issues/new).
