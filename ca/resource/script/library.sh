readPassword() {
  local prompt="$1"
  local variable="$2"

  set "$variable"=''
  read -s -p "$prompt " "$variable"
  echo ''

  return 0
}


verifyPassword() {
  local prompt1="$1"
  local prompt2="$2"
  local variable="$3"

  local password1=''
  readPassword "$prompt1" password1

  local password2=''
  readPassword "$prompt2" password2

  if [ "$password1" != "$password2" ]; then
    return 1
  fi

  eval "$variable"="$password1"

  unset password1
  unset password2

  return 0
}


initializeCADir() {
  local rootDir="$1"

  if [ "$rootDir" == '' ]; then
    echo 'Must specify rootDir' > /dev/stderr
    return 1
  fi

  test -d "$rootDir"           || mkdir       "$rootDir"
  test -d "$rootDir/certs"     || mkdir       "$rootDir/certs"
  test -d "$rootDir/newcerts"  || mkdir       "$rootDir/newcerts"
  test -d "$rootDir/crl"       || mkdir       "$rootDir/crl"
  test -d "$rootDir/private"   || mkdir       "$rootDir/private"
  test -d "$rootDir/requests"  || mkdir       "$rootDir/requests"
  test -f "$rootDir/serial"    || echo '00' > "$rootDir/serial"
  test -f "$rootDir/crlnum"    || echo '00' > "$rootDir/crlnum"
  test -f "$rootDir/index.txt" || touch       "$rootDir/index.txt"

  return 0
}
