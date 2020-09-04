{
  disable(message):: {
    name: 'disable puppet',
    command: "puppet agent --disable '%s'" % message,
  },
  enable:: {
    name: 'enable puppet',
    command: 'puppet agent --enable',
  },
  run:: {
    name: 'run puppet',
    command: 'puppet agent -t',
    register: 'result',
    until: 'result.rc == 0',
    retries: 10,
    delay: 60,
  },
}
