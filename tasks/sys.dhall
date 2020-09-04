let Ansible =
    -- https://raw.githubusercontent.com/softwarefactory-project/dhall-ansible/master/package.dhall
      https://raw.githubusercontent.com/retzkek/dhall-ansible/master/package.dhall sha256:50595ec584149cfbdb8f763d629af0315c893f6937a4c2502b425e06372d44d9

in  { renewTicket = Ansible.Task::{
      , name = Some "renew kerberos ticket"
      , delegate_to = Some "127.0.0.1"
      , command = Some "kinit -R"
      }
    , declareDowntime = Ansible.Task::{
      , name = Some "declare downtime"
      , command = Some "set_my_downtime"
      }
    , reboot = Ansible.Task::{
      , name = Some "reboot node"
      , reboot = Some Ansible.Reboot::{ reboot_timeout = Some 3600 }
      }
    }
