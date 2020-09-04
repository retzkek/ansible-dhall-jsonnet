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
