$CAContainerName = 'certificate-authority';

$ReasonList = @(
  'unspecified',
  'keyCompromise',
  'CACompromise',
  'affiliationChanged',
  'superseded',
  'cessationOfOperation',
  'certificateHold',
  'removeFromCRL'
);

function Read-DistinguishedName() {
  $dn = Read-Host -Prompt 'Distinguished Name (DN)';
  if ([string]::IsNullOrEmpty($dn)) {
    throw 'Distinguished Name (DN) must not be empty.';
  }

  return $dn;
}

function Read-CRLReason() {
  $reason = Read-Host -Prompt "Certification Revokation Reason`r`nChoose in: $($ReasonList -join ', ')";

  if ([string]::IsNullOrEmpty($reason)) {
    throw 'Certification Revokation Reason must not be empty.';
  } elseif (!($ReasonList -contains $reason)) {
    throw "Certification Revokation Reason must be in following values.`r`n$($ReasonList -join ', ')";
  }

  return $reason;
}

$DN = Read-DistinguishedName;
$CRL_REASON = Read-CRLReason;

$command += "DN='${DN}' ";
$command += "CRL_REASON='${CRL_REASON}' ";
$command += 'revoke_server && generate_crl';

docker exec $CAContainerName sh -c "$command";
