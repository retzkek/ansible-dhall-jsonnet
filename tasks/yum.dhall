let Ansible =
    -- https://raw.githubusercontent.com/softwarefactory-project/dhall-ansible/master/package.dhall
      https://raw.githubusercontent.com/retzkek/dhall-ansible/master/package.dhall sha256:50595ec584149cfbdb8f763d629af0315c893f6937a4c2502b425e06372d44d9

in  { removeVersionLock = Ansible.Task::{
      , name = Some "remove yum version lock"
      , command = Some "yum versionlock clear"
      }
    , update = Ansible.Task::{
      , name = Some "yum update"
      , yum = Some Ansible.Yum::{ name = [ "*" ], state = Some "latest" }
      }
    }
