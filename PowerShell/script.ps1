$BASEURL = "https://your-gmsp-instance"
$USERNAME ="mail@example.com"
$PASSWORD ="password"


function FetchRealmAndClientId()
{
    $response = Invoke-WebRequest -Method GET -Uri ("$BASEURL/mssp-admin/public/config/realm")
    return ConvertFrom-Json $([String]::new($response.Content) )
}


function GetToken($ClientId, $RealmId)
{
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }

    $body = "grant_type=password" +  `
             "&username=" + [System.Web.HttpUtility]::UrlEncode($USERNAME) +  `
             "&password=" + [System.Web.HttpUtility]::UrlEncode($PASSWORD) +  `
             "&client_id=" + $ClientId

    $response = Invoke-WebRequest -Method POST -Headers $headers -Body $body -Uri ("$BASEURL/auth/realms/$RealmId/protocol/openid-connect/token")
    return ConvertFrom-Json $([String]::new($response.Content))
}


function GetTargets()
{
    $idContainer = FetchRealmAndClientId
    $token = GetToken -ClientId $idContainer.clientId -RealmId $idContainer.realm

    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "bearer $($token.access_token)"
    }

    $response = Invoke-WebRequest -Method GET -Headers $headers -Uri ("$BASEURL/targets")
    return ConvertFrom-Json $([String]::new($response.Content))

}


$targets = GetTargets
echo $targets