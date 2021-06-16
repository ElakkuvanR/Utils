[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor
[Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest http://localhost:8984/solr -UseBasicParsing -Method Post -Body '{"id":"xdb-rebuild-status","lastupdated_dt":"2017-05-24T10:15:47.603436Z","rebuildstate_l":1,"progresstotal_d":0.0,"progresscurrent_d":0.0}'
