<#===========================================================================================================================================================

                            @+
                         @  @@#
                        *+@ @*@
                        @+@@***@                       :WWWW#                                         WWW
                        @**@+**@                      WWWWWWWW                                        WWW
                        @**@+***@                    WWWWWWWW                                         WWW
                        @@+@+***@@                   WWW                                              WWW
                        #++@+***@*@                 WWW         WW #WW  WWWWWW    WWWWWW   WWW WWWW,  WW.WWWWW   WWWWWW    WW #WWWW   WWWWWW
                      :++*******@*@                 WWW         WWWWWW WWWWWWWW  WWWWWWWW  WWWWWWWWW  WWWWWWWW  WWWWWWWW   WWWWWWWW  WWWWWWWW
                     @+*********@*+@                WWW    WWW  WWWW   WWW   WW  WWW   WW  WWWW  WWW  WWW   WWW WWW   WWW  WWW   WW+ WWW   WW
                    @***********#*+@                WWW    WWW  WWW    WWW   WW  WW+   WW  WWW   WWW  WWW   WWW WW#   WWW  WW+   WW+ WW+   WW
                   @++@************+@               WWW    WWW  WWW    WWWWWWWW  WWWWWWWW  WWW   WWW  WWW   WWW WW.   WWW  WW+   WW+ WWWWWWWW
                  @+*@@.@**********+@               WWW    WWW  WWW    WWWWWWW   WWWWWW#   WWW   WWW  WWW   WWW WW#   WWW  WW+   WW+ WWWWWW#
                 @+*+@   +****+@@@@*@                WWW   WWW  WWW    WWW       WWW       WWW   WWW  WWW   WW# WWW   WWW  WW+   WW+ WWW
                @+*+@    ****@@+**@+@@               WWWWWWWWW  WWW    WWWWWWWW  WWWWWWWW  WWW   WWW  WWWWWWWW  WWWWWWWW   WW+   WW+ WWWWWWWW
               @+**+@   @***@@****@##++@              WWWWW WW  WWW     WWWWWWW   WWWWWWW  WWW   WWW  WWWWWWW    WWWWWW    WW+   WW+  WWWWWWW
              ,++**+@ :@****@******@*++@
              *+***+********@+******@*@@@
             @+**************@*******@@+@
            ,++**************#+*******@*@:
            @+***************@++******@*@           ************************************************************************************************************
           #+**************@@@@+*****++*@           PowerShell Script demonstrating the how to obtain a JWT token for the GMSP https://www.greenbone.net/gmsp/ .
           #+#************@  @@@+****@@@            Please fill in your credentials and baseUrl. Examples are provided.
          :+*@@**********@  :# @+****@
          @++@@*********@@ ,@  @+***@               To obtain a token the correct clientId and reamId are required. These can be fetched for the domain
          +************@@  @  @++**@                under /mssp-admin/public/config/realm . For example https://admingmsp.adn.de/mssp-admin/public/config/realm .
          **********@@W  @@  @++**@:                Although this script fetches them automatically.
          @********@  *@@   @++**@*
          *+******@  @.   @#+***@,                  Using the wrong clientId will generally result in an "error":"unauthorized_client".
           @+****** @    @+***#@                    This $token.Content variable at the end will contain the access_token, refresh_token and token_type.
            @@+*#@@     @+***@@                     To make an Authenticated request use the access_token and token type in an "Authorization" request header.
              #@,  @  @++**+@,                      For example "Authorization: $token_type $access_token" this should result in "Authorization: bearer eyJhb....."
                    @@+***@@
                     #+*@#                          Tested on:
                                                    Date:       2021.08.01
                                                    PowerShell: 5.1.19041.610
                                                    Windows:    Microsoft Windows NT 10.0.19042.0
===============================================================================================================================================================#>



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