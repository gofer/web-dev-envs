$CAContainerName = 'certificate-authority';
$NginxContainerName = 'reverse-proxy';

function Read-Password() {
  return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(
      (Read-Host -Prompt 'Password' -AsSecureString)
    )
  );
}

function Read-Subject() {
  $C = Read-Host -Prompt 'C (Country [2-letter code], default is ''JP'')';
  if ([string]::IsNullOrEmpty($C)) {
    $C = 'JP';
  }
  
  $ST = Read-Host -Prompt 'ST (State or Province)';
  if ([string]::IsNullOrEmpty($ST)) {
    $ST = '';
  }
  
  $L = Read-Host -Prompt 'L ((City or Locality)';
  if ([string]::IsNullOrEmpty($L)) {
    $L = '';
  }
  
  $O = Read-Host -Prompt 'O (Organization)';
  if ([string]::IsNullOrEmpty($O)) {
    $O = '';
  }
  
  $OU = Read-Host -Prompt 'OU (Organization Unit)';
  if ([string]::IsNullOrEmpty($OU)) {
    $OU = '';
  }
  
  $CN = Read-Host -Prompt 'CN (Common Name, ex. www.example.com)';
  if ([string]::IsNullOrEmpty($CN)) {
    throw 'Common Name (CN) must not be empty.';
  }
  
  $SAN = Read-Host -Prompt (`
    "Subject Alternative Name`n" +
    "  !!! Do NOT specify ""DNS:$CN"" !!!`n" +
    '  (ex. DNS:www.example.com,DNS:mail.example.com,IP:12.34.56.78)'
  );
  if ([string]::IsNullOrEmpty($SAN)) {
    $SAN = '';
  }

  return [PSCustomObject]@{
    C = $C
    ST = $ST
    L = $L
    O = $O
    OU = $OU
    CN = $CN
    SAN = $SAN
  };
}

function Build-SubjectString([PSCustomObject] $subject) {
  $string = '';

  if (![string]::IsNullOrEmpty($subject.C)) {
    $string += "/C=$($subject.C)";
  }

  if (![string]::IsNullOrEmpty($subject.ST)) {
    $string += "/ST=$($subject.ST)";
  }

  if (![string]::IsNullOrEmpty($subject.L)) {
    $string += "/L=$($subject.L)";
  }

  if (![string]::IsNullOrEmpty($subject.O)) {
    $string += "/O=$($subject.O)";
  }

  if (![string]::IsNullOrEmpty($subject.OU)) {
    $string += "/OU=$($subject.OU)";
  }

  $string += "/CN=$($subject.CN)";

  return $string;
}

function Build-SANString([PSCustomObject] $subject) {
  $string = "DNS:$($subject.CN)";
  if (![string]::IsNullOrEmpty($subject.SAN)) {
    $string += ",$($subject.SAN)";
  }
  return $string;
}

function CopyMaterialsToNginxContainer([string] $commonName) {
  $privateKeyFile = "${commonName}.nopass.pem";
  $privateKeyFilePath = "/etc/ssl/inter_ca/private/${privateKeyFile}";
  docker cp "${CAContainerName}:${privateKeyFilePath}" '.';
  docker cp $privateKeyFile "${NginxContainerName}:/etc/ssl/private/${privateKeyFile}";
  
  $certFile = "${commonName}.crt";
  $certFilePath = "/etc/ssl/inter_ca/certs/${certFile}";
  docker cp "${CAContainerName}:${certFilePath}" '.';
  docker cp ${certFile} "${NginxContainerName}:/etc/ssl/certs/${certFile}";
  
  $certChainFile = "${commonName}.chain.crt";
  $certChainFilePath = "/etc/ssl/inter_ca/certs/${certChainFile}";
  docker cp "${CAContainerName}:${certChainFilePath}" '.';
  docker cp ${certChainFile} "${NginxContainerName}:/etc/ssl/certs/${certChainFile}";
}

$password = Read-Password;

$subject = Read-Subject;

$command  = "SERVER_PASSWORD='$password' ";
$command += "DN='$($subject.CN)' ";
$command += "SUBJECT='$(Build-SubjectString $subject)' ";
$command += "SAN='$(Build-SANString $subject)' ";
$command += 'generate_server && generate_crl';

docker exec $CAContainerName sh -c "$command";

CopyMaterialsToNginxContainer $subject.CN;
