saltstack-installer
=========
[![Build Status](https://travis-ci.org/denis-kalinin/saltstack-installer.svg?branch=master)](https://travis-ci.org/denis-kalinin/saltstack-installer)

There was a joke:
> &mdash; What is there Internet Explorer on Windows for?  
> &mdash; Just to download Firefox!

The same I would say about Ansible and Saltstack. Indeed there is Salt-SSH, but
it has some disadvantages versus Ansible for agentless configuration:
- doesn't work on Windows
- [has bug with Jinja template]

Saltstack is more robust and flexible than Ansible, (*imho!!!*) and my tactic is to install
Saltstack and its configuration on nodes with Ansible.

Requirements
------------

- if you want [to run ansible playbook on Windows]

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

1. `dk_salt_master_addresses` &ndash; array of salt masters, to be provided to `dk_salt_minion_config`
2. `dk_salt_minion_config` &ndash; location of minion's jinja-template in your playbook
3. `dk_salt_master_config` &ndash; location of master's jinja-template in your playbook

### dk_salt_master_addresses
The array can be fetched, say, from group `[master]` in the playbook's inventory:
```dosini
[master]
10.24.53.2
10.24.53.4
```
Just add `pre_task`:
```yaml
  pre_tasks:
    - name: setting fact about masters IP addresses
      set_fact:
        master_ips: "{% set masters = [] %}{% for host in groups.master %}{% set masters = masters.append(hostvars[host].ansible_default_ipv4.address) %}{% endfor %}{{ masters | to_json }}"
      when: (master_ips is not defined)
```
and then, in the role definition:
```yaml
  roles:
    - role: saltstack-installer
      dk_salt_master_addresses: "{{master_ips}}"
      dk_salt_minion_config: "{{ minion_config_file | default(None) }}"
      dk_salt_master_config: "{{ master_config_file | default(None) }}"

```
### dk_salt_minion_config
`dk_salt_minion_config` should reside somewhere in your playbook. Example of minion config as Jinja template:
```yaml
master: {{ dk_salt_master_addressess }}
id: {{ inventory_hostname }}
hash_type: sha256
master_tries: -1
auth_tries: 15
auth_safemode: true
mine_interval: 3
startup_states: highstate
grains:
  role: {{ roles | to_json }}
  cluster: test-1
  {% if public_cname is defined -%}
  public_network:
    ip: {{ ansible_host }}
    cname: {{ public_cname }}
  {% endif %}

```

Dependencies
------------

This role doesn't depend on other roles.

Example Playbook
----------------

```yaml
---
- name: Install Salt minions on hosts
  hosts: all
  gather_facts: true
  become: false
  roles:
    - role: saltstack-installer
      dk_salt_master_addresses: "{{master_ips}}"
      dk_salt_minion_config: "{{ minion_config_file | default(None) }}"
      dk_salt_master_config: "{{ master_config_file | default(None) }}"
```

License
-------

MIT

Author Information
------------------

Denis Kalinin, http://github.com/denis-kalinin


[has bug with Jinja template]: https://github.com/saltstack-formulas/salt-formula/issues/140
[to run ansible playbook on Windows]: docs/ansible-on-windows.md
