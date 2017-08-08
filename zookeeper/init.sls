{% set version = '3.4.8' %}
{% set zk_home = '/var/zookeeper' %}
{% set myid = pillar.get('myid') %}
{% set service_id = pillar.get('service_id') %}

deregister:
  module.run:
    - name: consul.agent_service_deregister
    - consul_url: 'http://localhost:8500'
    - serviceid: {{ service_id }}

register:
  module.run:
    - name: consul.agent_service_register
    - consul_url: 'http://localhost:8500'
    - kwargs: {
          name: 'zookeeper',
          id: {{ service_id }},
          tags: ["{{ myid }}"]
      }

# /etc/consul.d/zookeeper_{{ service_id }}:
#   file.managed:
#     - contents:
#       - '{'
#       - '  "services": ['
#       - '    {'
#       - '        "ServiceID": "zookeeper",'
#       - '        "ServiceName": "zookeeper",'
#       - '        "ServiceTags": ['
#       - '            "0"'
#       - '        ]'
#       - '    }'
#       - '  ]'
#       - '}'

'systemctl restart consul':
  cmd.run:
    - onchanges:
      - file: /etc/consul.d/zookeeper_{{ service_id }}

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
    - unless: test -d {{ zk_home }}/zookeeper-{{ version }}
    - user: root
    - group: root
    - trim_output: 5

/var/zookeeper_data/myid:
  file.managed:
    - contents:
      - {{ myid }}

/etc/consul-template/tmpl-source/zoo.cfg:
  file.managed:
    - template: jinja
    - source: salt://zookeeper/files/zoo.cfg.ctmpl

/etc/consul-template.d/zk.json:
  file.managed:
    - template: jinja
    - source: salt://zookeeper/files/zookeeper.json
    - content:
      zk_home: {{ zk_home }}
      version: {{ version }}

consul-template:
  service.running:
    - restart: true
    - onchanges:
      - file: /etc/consul-template/tmpl-source/zoo.cfg
      - file: /etc/consul-template.d/zk.json
