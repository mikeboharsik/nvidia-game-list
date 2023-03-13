$fingerprintPath = "$ENV:LOCALAPPDATA\NVIDIA\NvBackend\ApplicationOntology\data\fingerprint.db"

$databaseInfo = Get-ChildItem $fingerprintPath

$processedData = Select-Xml -Path $fingerprintPath -Xpath '//Fingerprint'
	| ForEach-Object {
		$node = $_.node

		$versions = $node.version | ForEach-Object {
			return [ordered]@{
				name = $_.name
				files = $_.files.file | ForEach-Object { $_.name }
			}
		}

		return [ordered]@{
			displayName = $node.displayName
			name = $node.name
			versions = $versions
		}
	} | Sort-Object { $_.name }

$driverVersion = Get-WmiObject Win32_VideoController | Select-Object -ExpandProperty DriverVersion

[ordered]@{
	databaseLastWriteTimeUtc = $databaseInfo.LastWriteTimeUtc
	driverVersion = $driverVersion
	games = $processedData
}	| ConvertTo-Json -Depth 10
	| Set-Content "games.json"
