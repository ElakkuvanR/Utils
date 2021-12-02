$redisConnectionString = "redis://clientid:<connectionstring>:6380?ssl=true&db=10&ConnectTimeout=3000";

Write-Host "Flushing cache on host Started " $redisConnectionString -ForegroundColor Yellow

Add-Type -path "\\docker\\deploy\\cm\\bin\\ServiceStack.Redis.dll"
Add-Type -path "\\docker\\deploy\\cm\\bin\\ServiceStack.Text.dll"
Add-Type -path "\\docker\\deploy\\cm\\bin\\ServiceStack.Common.dll"
Add-Type -path "\\docker\\deploy\\cm\\bin\\ServiceStack.Interfaces.dll"

#Connect to Redis Server
$redismanager = [ServiceStack.Redis.RedisManagerPool]::New($redisConnectionString)

#Get the Client
$redisClient = $redismanager.GetClient()

#All keys
$allKeys = $redisClient.GetAllKeys()

foreach ($key in $allKeys) {
    if( $key -like '*master' -or $key -like '*web')
    {
        #$redisClient.Remove(sitemapKey);
        Write-Host "Removing the keys " $key -ForegroundColor Yellow
    }
}

Write-Host "Flushing cache on host Ended" -ForegroundColor Yellow


