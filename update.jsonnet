local t = import 'tasks/package.libsonnet';

function(username='ifmon') [{
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
