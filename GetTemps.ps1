$request = 'http://192.168.2.227/get'
Invoke-WebRequest $request | ConvertFrom-Json | %{ "{0}, {1}, {2}" -f $_.temp, $_.humidity, $_.switch_state } | Out-File templog.txt -Append