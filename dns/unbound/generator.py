import os
import re
from jinja2 import Template

TemplateFilePath = '/tmp/unbound.conf.in'
OutputFilePath = '/tmp/unbound.conf'
ZonesDirPath = '/tmp/zones'

templateFile = open(TemplateFilePath, mode='r')
templateContent = templateFile.read()
templateFile.close()

cidr_pattern = '(\d+\.\d+\.\d+\.\d+)/(\d+)'
cidr_match = re.match(cidr_pattern, os.environ['IPV4_INTERNAL_IPRANGE'])
if cidr_match == None:
  raise ValueError('`IPV4_INTERNAL_IPRANGE` is not CIDR format.' + "\n" + os.environ['IPV4_INTERNAL_IPRANGE'])

ipv4_cidr = os.environ['IPV4_UNBOUND_INTERNAL_ADDR']  + '/' + cidr_match[2]

is_zone_file = lambda path: os.path.isfile(path) and path.endswith('.zone')
zone_files = [ file for file in map(lambda name: os.path.join(ZonesDirPath, name), os.listdir(ZonesDirPath)) if is_zone_file(file) ]
zone_file_path_to_object = lambda path: {
  'name': re.match('(.+)\.zone', os.path.basename(path))[1],
  'authority': {
    'ipv4': os.environ['IPV4_NSD_INTERNAL_ADDR'],
    'port': 53
  },
  'secure': False
}

args = {
  'container': {
    'ipv4': os.environ['IPV4_UNBOUND_INTERNAL_ADDR'],
    'ipv4_cidr': ipv4_cidr,
  },
  'dns': {
    'primary': os.environ['DNS_PRIMARY'],
    'secondary': os.environ['DNS_SECONDARY']
  },
  'zones': list(map(zone_file_path_to_object, zone_files))
}

content = Template(templateContent).render(args)

outputFile = open(OutputFilePath, mode='w')
outputFile.write(content)
outputFile.close()
