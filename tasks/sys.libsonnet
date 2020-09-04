{
  renewTicket: {
    name: 'renew kerberos ticket',
    delegate_to: '127.0.0.1',
    command: 'kinit -R',
  },
  declareDowntime: {
    name: 'declare downtime',
    command: 'set_my_downtime',
  },
  reboot: {
    name: 'reboot node',
    reboot: {
      reboot_timeout: 3600,
    },
  },
}
