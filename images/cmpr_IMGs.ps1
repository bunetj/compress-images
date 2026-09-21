param(
    [int]$r = 0,
    [int]$s = 0,
    [switch]$replace,
    [switch]$jpg,
    [switch]$recurse,
    [switch]$resize
)

Add-Type -AssemblyName System.Drawing

$getParams = @{
    Path = "."
    File = $true
}
if ($recurse) {
    $getParams.Recurse = $true
}

$images = Get-ChildItem @getParams | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|gif|bmp|tiff|webp|heic)$' }

if ($r -gt 0) {
    $images = $images | Where-Object { 
        $img = [System.Drawing.Image]::FromFile($_.FullName)
        $width = $img.Width
        $height = $img.Height
        $img.Dispose()
        $width -gt ($r * 1000) -or $height -gt ($r * 1000)
    }
}

if ($s -gt 0) {
    $images = $images | Where-Object { $_.Length -gt ($s * 1MB) }
}

if (-not $replace) {
    $currentFolder = Get-Location
    $compressedFolder = Join-Path -Path $currentFolder.Parent.FullName -ChildPath ($currentFolder.Name + "_compressed")
    New-Item -ItemType Directory -Path $compressedFolder -Force | Out-Null
}

if ($resize) {
    foreach ($image in $images) {
        $img = [System.Drawing.Image]::FromFile($image.FullName)
        
        $newWidth = [int]($img.Width * 0.5)
        $newHeight = [int]($img.Height * 0.5)
        $thumbnail = new-object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($thumbnail)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)
        
        if ($replace) {
            # Save to temp file first, then replace
            $tempPath = [System.IO.Path]::GetTempFileName() + ".tmp"
            if ($jpg) {
                $thumbnail.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            } else {
                # Determine format from extension
                $ext = [System.IO.Path]::GetExtension($image.FullName).ToLower()
                switch ($ext) {
                    ".jpg" { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
                    ".jpeg" { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
                    ".png" { $format = [System.Drawing.Imaging.ImageFormat]::Png }
                    ".gif" { $format = [System.Drawing.Imaging.ImageFormat]::Gif }
                    ".bmp" { $format = [System.Drawing.Imaging.ImageFormat]::Bmp }
                    ".tiff" { $format = [System.Drawing.Imaging.ImageFormat]::Tiff }
                    default { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
                }
                $thumbnail.Save($tempPath, $format)
            }
            
            # Replace original with temp file
            $img.Dispose()
            $thumbnail.Dispose()
            $graphics.Dispose()
            Remove-Item $image.FullName -Force
            Move-Item $tempPath $image.FullName -Force
            continue
        } else {
            $relativePath = if ($recurse) {
                $currentFolder = Get-Location
                $relative = $image.Directory.FullName.Substring($currentFolder.FullName.Length + 1)
                if ($relative) { $relative + "\" } else { "" }
            } else { "" }
            
            $targetDir = Join-Path -Path $compressedFolder -ChildPath $relativePath
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            
            $outputName = if ($jpg) { 
                [System.IO.Path]::ChangeExtension($image.Name, ".jpg") 
            } else { 
                $image.Name 
            }
            $outputPath = Join-Path -Path $targetDir -ChildPath $outputName
            
            if ($jpg) {
                $thumbnail.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            } else {
                # Determine format from extension
                $ext = [System.IO.Path]::GetExtension($image.FullName).ToLower()
                switch ($ext) {
                    ".jpg" { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
                    ".jpeg" { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
                    ".png" { $format = [System.Drawing.Imaging.ImageFormat]::Png }
                    ".gif" { $format = [System.Drawing.Imaging.ImageFormat]::Gif }
                    ".bmp" { $format = [System.Drawing.Imaging.ImageFormat]::Bmp }
                    ".tiff" { $format = [System.Drawing.Imaging.ImageFormat]::Tiff }
                    default { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
                }
                $thumbnail.Save($outputPath, $format)
            }
        }
        
        $img.Dispose()
        $thumbnail.Dispose()
        $graphics.Dispose()
    }
}
