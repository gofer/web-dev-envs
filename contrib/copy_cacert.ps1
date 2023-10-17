$ContainerName = 'certificate-authority';

$rootCACertPath = '/etc/ssl/root_ca/certs/root_ca.crt';
docker cp "${ContainerName}:${rootCACertPath}" '.';

$interCACertPath = '/etc/ssl/inter_ca/certs/inter_ca.crt';
docker cp "${ContainerName}:${interCACertPath}" '.';
