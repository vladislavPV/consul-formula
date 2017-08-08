{% from slspath+"/map.jinja" import consul with context %}

consul-config:
  file.managed:
    - name: /etc/consul.d/config.json
    {% if consul.service != False %}
    - watch_in:
       - service: consul
    {% endif %}
    - user: consul
    - group: consul
    - require:
      - user: consul
    - contents: |
        {{ consul.config | json }}

{% if consul.config.ui != False %}

nginx:
  pkg.installed

consul_nginx_config:
  file.managed:
    - source: salt://consul/files/nginx.conf

systemctl restart nginx:
  cmd.run:
    - onchanges:
      - file: consul_nginx_config
      - pkg: nginx

{% endif %}

{% for script in consul.scripts %}
consul-script-install-{{ loop.index }}:
  file.managed:
    - source: {{ script.source }}
    - name: {{ script.name }}
    - template: jinja
    - user: consul
    - group: consul
    - mode: 0755
{% endfor %}

consul-script-config:
  file.managed:
    - source: salt://{{ slspath }}/files/services.json
    - name: /etc/consul.d/services.json
    - template: jinja
    {% if consul.service != False %}
    - watch_in:
       - service: consul
    {% endif %}
    - user: consul
    - group: consul
    - require:
      - user: consul
    - context:
        register: |
          {{ consul.register | json }}
