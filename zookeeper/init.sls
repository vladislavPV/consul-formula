
java:
  pkg.installed

/etc/systemd/system/zookeeper.service:
  file.managed:
    - template: jinja
    - source: salt://zookeeper/files/zookeeper.service
    - content:
      version: 3.4.8

/var/zookeeper:
  file.directory


install-zookeeper:
  archive.extracted:
    - name: /var/zookeeper
    - source: http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz
    - skip_verify: True
    - archive_format: tar
    #- if_missing: /lib
    - user: root
    - group: root

