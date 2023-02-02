#$ORACLE_HOME = "{{ oracleclient_home }}"
$TNSNAMES_FILE = "tnsnames.ora"
$ENTRY_NAME = $args[0]
$HOST_ADDR = $args[1]
$PORT_NUM = $args[2]
$SRV_NAME = $args[3]
$TNS_ADMIN_DIR = $args[4]

if ($null -eq $ENTRY_NAME -or $null -eq $HOST_ADDR -or $null -eq $PORT_NUM -or $null -eq $SRV_NAME -or $null -eq $TNS_ADMIN_DIR) {
  Write-Output "Missing one or more required parameters: [ENTRY_NAME] [HOST_ADDR] [PORT_NUM] [SERVICE_NAME] [TNS_ADMIN_DIR]"
  exit
}

$chk_entry = Get-Content "$TNS_ADMIN_DIR\$TNSNAMES_FILE" | Select-String "$ENTRY_NAME =" | Measure-Object | Select-Object -ExpandProperty Count

if ($null -ne $chk_entry -and $chk_entry -eq 0) {
  Write-Output "Creating the required entry..."
  Write-Output ""

  $entry = @"
$ENTRY_NAME =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $HOST_ADDR)(PORT = $PORT_NUM))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = $SRV_NAME)
    )
  )
"@
  Add-Content "$TNS_ADMIN_DIR\$TNSNAMES_FILE" $entry
}
elseif ($chk_entry -ne 0) {
  Write-Output ""
  Write-Output "This entry already exists: [$ENTRY_NAME]."
  Write-Output "Nothing to do!"
  Write-Output ""
  exit
}
