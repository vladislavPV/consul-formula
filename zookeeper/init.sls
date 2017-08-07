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

zookeeper-dirs:
  file.directory:
    - names:
      - /var/zookeeper
      - /var/zookeeper_data

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

/var/zookeeper_data/myid:
  file.managed:
    - contents:
      - {{ grains['id'] }}

/etc/consul-template/tmpl-source/zoo.cfg:
  file.managed:
    - template: jinja
    - source: salt://zookeeper/files/zoo.cfg.ctmpl

/etc/consul-template.d/zk.json:
  file.managed:
    - template: jinja
    - source: salt://zookeeper/files/zookeeper.json

consul-template:
  service.running:
    - restart: true
    - onchanges:
      - file: {{ zk_home }}/zookeeper-{{ version }}/conf/zoo.cfg
      - file: /etc/consul-template.d/zk.json