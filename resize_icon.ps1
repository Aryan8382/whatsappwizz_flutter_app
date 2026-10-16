Add-Type -AssemblyName System.Drawing

$srcPath = "D:\WABA ANDROID APP\whatsapp_wiz\assets\images\app_icon.png"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)
Write-Host "Original dimensions: $($bmp.Width) x $($bmp.Height)"

# Resize / convert to true 1024x1024 PNG
$canvas = New-Object System.Drawing.Bitmap(1024, 1024, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($canvas)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.DrawImage($bmp, 0, 0, 1024, 1024)

$bmp.Dispose()
$canvas.Save($srcPath, [System.Drawing.Imaging.ImageFormat]::Png)
$canvas.Dispose()
$graphics.Dispose()
Write-Host "Successfully saved 1024x1024 PNG icon to $srcPath"
