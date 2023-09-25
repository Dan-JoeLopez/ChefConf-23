# ChefConf23 Extensibility Example

This cookbook supplies the code that accompanies the ChefConf presentation on extending Chef infra cookbooks.

## Dependencies
This cookbook has no external dependecies.

## Supported OS
* Windows Server
  * 2012ad_vulnerabilies
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

### BW1-00-02
Separation of duties and purposes
* OHAI: node['hardening']['BW1-00-02']
  * `compliant`: bool check to see if the system is compliant with the policy
  * `offenses`: String explaining how the policy is being violated
  * `desired_roles`: Array of which special roles are to remain installed
  * `undesired_roles`: Array of roles/features that are to be removed

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

### Destructive Policies
 
* BW 1.00.02 Separation of duties and purposes
  * For the purpose of the demonstration, we will be writing code that intends to remove roles/features.
  * This would be highly destructive, and not suitable for a production envronment!


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

* [Dan-Joe Loepz](Dan-Joe.Loepz@sap.com)

### License

For SAP Internal Use ONLY, not licensed for external contribution or
distribution.

## Support

If you need help with this cookbook, please raise an [issue on git](https://github.com/SAPDanJoe/ChefConf-23/issues/new).
