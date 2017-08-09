{% set dns_servers = salt['cmd.shell']('cat /etc/resolv.conf |grep name|cut -d" " -f2|xargs').split(" ") %}

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


/etc/resolv.conf:
  file.replace:
    - pattern: 'nameserver.*$'
    - repl: 'nameserver 127.0.0.1'
    - append_if_not_found: true


systemctl restart dnsmasq:
  cmd.run:
    - onchanges:
      - file: /etc/dnsmasq.d/99-default
      - file: /etc/dnsmasq.d/10-consul