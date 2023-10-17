$ContainerName = 'certificate-authority';

function Build-Timestamp() {
  return Get-Date -Format 'yyyyMMddHHmmssffff';
}

$backupFilePath = "/tmp/backup-$(Build-Timestamp).tar.xz";

$command = "tar cv -f ${backupFilePath} -C /etc/ssl root_ca inter_ca";
docker exec $ContainerName sh -c $command;

docker cp "${ContainerName}:${backupFilePath}" '.';

docker exec $ContainerName rm $backupFilePath;
