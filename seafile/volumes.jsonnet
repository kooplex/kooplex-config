local Config = import 'config.libsonnet';

{
  'volumes.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
        Config.PV(Config.appname + '-data', cap='1T', path=Config.nfsvol),
        Config.PVC(Config.appname + '-data', Config.appname + '-data', cap='1T'),
      ],
  },
}
