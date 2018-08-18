# POST method: $req
$requestBody = Get-Content $req -Raw | ConvertFrom-Json

# Get MSI Endpoint and MSI Secret from environment variables
$MSIEndpoint = $env:MSI_ENDPOINT
$MSISecret = $env:MSI_SECRET

# Get Vault Name from environment variables
$vaultName = $env:key_vault_name

# The secret name
$secretName = "iamasecret"

# Get authorization token for the key vault 
$vaultTokenUri = $MSIEndpoint + "?resource=https://vault.azure.net&api-version=2017-09-01"
$authenticationResult = Invoke-RestMethod -Method Get -Headers @{"Secret" = $MSIsecret} -Uri $vaultTokenUri
$accessToken = $authenticationResult.access_token

# Get the secret value
$vaultSecretURI = "https://$vaultName.vault.azure.net/secrets/$secretName/?api-version=2015-06-01"
$secretResult = Invoke-RestMethod -Method GET -Uri $vaultSecretURI -ContentType "application/json" -Headers @{ Authorization = "Bearer $accessToken" }

# Best practice, write secret value in logs :) Only for demo purpose
Write-Output "Secret $secretName value is ""$($secretResult.Value)"""