let Ansible =
    -- https://raw.githubusercontent.com/softwarefactory-project/dhall-ansible/master/package.dhall
      https://raw.githubusercontent.com/retzkek/dhall-ansible/master/package.dhall sha256:50595ec584149cfbdb8f763d629af0315c893f6937a4c2502b425e06372d44d9

in  { disable =
        λ(message : Text) →
          Ansible.Task::{
          , name = Some "disable puppet"
          , command = Some "puppet agent --disable '${message}'"
          }
    , enable = Ansible.Task::{
      , name = Some "enable puppet"
      , command = Some "puppet agent --enable"
      }
    , run = Ansible.Task::{
      , name = Some "run puppet"
      , command = Some "puppet agent -t"
      , register = Some "result"
      , until = Some "result.rc == 0"
      , retries = Some 10
      , delay = Some 60
      }
    }
