$ContainerName = 'certificate-authority';

$timestamp = Get-Date -Format 'yyyyMMddHHmmssffff';

$backupFilePath = "/tmp/backup-${timestamp}.tar.xz";

$command = "tar cv -f ${backupFilePath} -C /etc/ssl root_ca inter_ca";
docker exec $ContainerName sh -c $command;

docker cp ("${ContainerName}:${backupFilePath}") '.';

docker exec $ContainerName rm $backupFilePath;
