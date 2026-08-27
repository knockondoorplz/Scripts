param ([string]$filePath)

# Define your collector path
$collectorPath = "C:\Users\brigi\Documents\Jason\Word Documents"

# Copy the file to the collector directory
Copy-Item $filePath -Destination $collectorPath -Force