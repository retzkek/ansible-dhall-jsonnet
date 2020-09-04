This is a comparison of a simple Ansible playbook rewritten in a modular format
using both [dhall](https://dhall-lang.org) and [jsonnet](https://jsonnet.org).
*Disclaimer:* I am far from an expert in any these three things, so there's
probably some less-than-best-practices. I also haven't actually tried running
the generated playbooks (but I did sytax-check them).

The original YAML config, which runs a system update procedure, is in
`update_original.yaml`. Jsonnet input is in `update.jsonnet` and output is in
`update_jsonnet.json`. Dhall input in `update.dhall` and output is in
`update_dhall.yaml`, and for sake of comparison with jsonnet
`update_jsonnet.json`.

There are two differences betwen the dhall and jsonnet playbooks, both caused by
the flexibility of Ansible allowing a field to be either a list of strings or
just a string when there's only one item (I'm not sure if that's universally
true or just for these options). It looks like dhall supports union types, so
this could probably be handled in the type library.

# Comparison

For a quick comparison, here are the "main" playbook files.

## YAML

``` yaml
- hosts: all
  remote_user: root
  # do one host at a time rather than several in parallel
  serial: 1
  tasks:
  - name: renew kerberos ticket
    local_action: command kinit -R
  - name: declare downtime
    command: set_my_downtime
  - name: disable puppet
    command: puppet agent --disable 'kretzke disabling to do docker update'
  - name: remove yum version lock
    command: yum versionlock clear
  - name: yum update
    yum:
      name: '*'
      state: latest
  - name: enable puppet
    command: puppet agent --enable
  - name: run puppet
    command: puppet agent -t
    register: result
    until: result.rc == 0
    retries: 10
    delay: 60
  - name: reboot node
    reboot:
      # some nodes can take a _long_ time to reboot
      reboot_timeout: 3600
```

## dhall

``` dhall
let Ansible =
    -- https://raw.githubusercontent.com/softwarefactory-project/dhall-ansible/master/package.dhall
      https://raw.githubusercontent.com/retzkek/dhall-ansible/master/package.dhall sha256:50595ec584149cfbdb8f763d629af0315c893f6937a4c2502b425e06372d44d9

let t = ./tasks/package.dhall

let user = env:USER as Text

in  [ Ansible.Play::{
      , hosts = "all"
      , remote_user = Some "root"
      , serial = Some [ "1" ]
      , tasks = Some
        [ t.sys.renewTicket
        , t.sys.declareDowntime
        , t.puppet.disable "${user} disabling to do docker update"
        , t.yum.removeVersionLock
        , t.yum.update
        , t.puppet.enable
        , t.puppet.run
        , t.sys.reboot
        ]
      }
    ]

```

## jsonnet

``` jsonnet
local t = import 'tasks/package.libsonnet';

function(username='kretzke') [{
  hosts: 'all',
  remote_user: 'root',
  serial: 1,
  tasks: [
    t.sys.renewTicket,
    t.sys.declareDowntime,
    t.puppet.disable('%s disabling to do docker update' % username),
    t.yum.removeVersionLock,
    t.yum.update,
    t.puppet.enable,
    t.puppet.run,
    t.sys.reboot,
  ],
}]

```

# Thoughts

* Both dhall and jsonnet are a big improvement over plan YAML, in high-level
  readability (at the expense of needing to dig a bit to get to implementation
  details), maintainability, and reuseability.
  
* Dhall has a lot of extra noise due to the typing (`Some` everywhere!). Perhaps
  with time one learns to push that to the background. It's also rather
  frustating when you find the type library is missing something, since you
  can't just work around that, and need to add it (I hear you strict-typing fans
  screaming "that's a feature!"). I had to make several additions to the
  [dhall-ansible](https://github.com/softwarefactory-project/dhall-ansible)
  library just for this short playbook (which were quickly accepted as PRs, so
  credit to the maintainer!).
  
* jsonnet feels very productive, although I should note that I was also working
  from the already-modularized dhall source. It's cleaner and more readable to
  my eyes, but again that may be familiarity, since dhall syntax is a bit alien
  (but probably not to a Haskeller).
  
# Conclusion

Comparing dhall and jsonnet is like comparing haskell and ~python~ lisp: do you
want the guarantees of type safety, or the productivity of a dynamic language?
Either is better than plain YAML (or python, down with significant whitespace)!

