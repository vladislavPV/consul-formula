{% set version = '3.4.8' %}
{% set zk_home = '/var/zookeeper' %}

java-1.8.0-openjdk:
  pkg.installed

/etc/systemd/system/zookeeper.service:
  file.managed:
    - template: jinja
    - source: salt://zookeeper/files/zookeeper.service
    - content:
      version: {{ version }}

/var/zookeeper:
  file.directory


install-zookeeper:
  archive.extracted:
    - name: {{ zk_home }}
    - source: http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-{{ version }}/zookeeper-{{ version }}.tar.gz
    - skip_verify: True
    - archive_format: tar
    - if_missing: {{ zk_home }}/zookeeper-{{ version }}
    - user: root
    - group: root
    - trim_output: 5

