{
  removeVersionLock: {
    name: 'remove yum version lock',
    command: 'yum versionlock clear',
  },
  update: {
    name: 'yum update',
    yum: {
      name: '*',
      state: 'latest',
    },
  },
}
