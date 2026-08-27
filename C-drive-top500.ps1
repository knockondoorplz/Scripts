$csv = "C:\Users\brigi\Desktop\C-drive-inventory.csv"

Import-Csv $csv |
    Sort-Object {[int64]$_.Size} -Descending |
    Select-Object -First 500 |
    Export-Csv "C:\Users\brigi\Desktop\C-drive-top500.csv" -NoTypeInformation