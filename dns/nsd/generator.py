import os
import re
from jinja2 import Template

TemplateFilePath = '/tmp/nsd.conf.in'
OutputFilePath = '/tmp/nsd.conf'
ZonesDirPath = '/tmp/zones'

templateFile = open(TemplateFilePath, mode='r')
templateContent = templateFile.read()
templateFile.close()

is_zone_file = lambda path: os.path.isfile(path) and path.endswith('.zone')
zone_files = [ file for file in map(lambda name: os.path.join(ZonesDirPath, name), os.listdir(ZonesDirPath)) if is_zone_file(file) ]
zone_file_path_to_object = lambda path: {
  'name': re.match('(.+)\.zone', os.path.basename(path))[1],
  'file': os.path.basename(path)
}

args = {
  'container': {
    'ipv4': os.environ['IPV4_NSD_INTERNAL_ADDR'],
  },
  'zones': list(map(zone_file_path_to_object, zone_files))
}

content = Template(templateContent).render(args)

outputFile = open(OutputFilePath, mode='w')
outputFile.write(content)
outputFile.close()
