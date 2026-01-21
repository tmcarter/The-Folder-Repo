# Specify the path to your CSV file
$csvPath = "C:\Project-26-01.csv"

# Specify the root directory where the "Clients-ID-Name" folder will be created
$rootDirectory = "C:\TEST-Folder\"

# Create the root folder if it does not exist (using -Force for idempotency)
$clientsFolder = Join-Path -Path $rootDirectory -ChildPath "Clients-ID-Name"
New-Item -ItemType Directory -Path $clientsFolder -Force | Out-Null

# Read data from CSV and create subfolders
Import-Csv -Path $csvPath | ForEach-Object {
    # Extract and trim values (handles null/empty as empty string)
    $id   = if ($_.ID)   { $_.ID.Trim() }   else { "" }
    $desc = if ($_.Description) { $_.Description.Trim() } else { "" }

    # Construct subfolder name; avoid trailing/leading hyphen or empty
    $subfolderName = "${id}-${desc}".Trim('-').Trim()

    # Skip if result is empty or only punctuation/whitespace after cleanup
    if ([string]::IsNullOrWhiteSpace($subfolderName) -or $subfolderName -eq "-") {
        Write-Warning "Skipping invalid/empty subfolder name for ID: '$id' Description: '$desc'"
        return
    }

    # Optional: Further sanitize to remove other unwanted trailing chars
    $subfolderName = $subfolderName.TrimEnd('-', '_', '.')

    $targetPath = Join-Path -Path $clientsFolder -ChildPath $subfolderName

    # Create with -Force (succeeds silently if exists; no error on re-run)
    try {
        New-Item -ItemType Directory -Path $targetPath -Force -ErrorAction Stop | Out-Null
        Write-Verbose "Processed: $subfolderName"
    }
    catch {
        Write-Error "Failed to create '$targetPath': $($_.Exception.Message)"
    }
}
