{% set dns_servers = salt['cmd.shell']('cat /etc/resolv.conf |grep name|cut -d" " -f2|xargs').split(" ") %}
{% set search = salt['cmd.shell']('cat /etc/resolv.conf |grep search') %}

/etc/dnsmasq.d/99-default:
  file.managed:
    - contents:
      {% for server in dns_servers %}
      - 'server={{ server }}'
      {% endfor %}
    - unless: test -f /etc/dnsmasq.d/99-default

/etc/dnsmasq.d/10-consul:
  file.managed:
    - contents:
      - 'server=/consul./127.0.0.1#8600'

comment_resolvers:
  file.comment:
    - name: /etc/resolv.conf
    - regex: ^.*$
    - char: ';'
    - onlyif: test -f /etc/dnsmasq.d/99-default

append_resolvers:
  file.append:
    - name: /etc/resolv.conf
    - text:
      - '{{ search }}'
      - 'nameserver 127.0.0.1'
    - onlyif: test -f /etc/dnsmasq.d/99-default

systemctl restart dnsmasq:
  cmd.run:
    - onchanges:
      - file: /etc/dnsmasq.d/99-default
      - file: /etc/dnsmasq.d/10-consul