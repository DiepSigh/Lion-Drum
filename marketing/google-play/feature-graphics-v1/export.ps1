# Export opaque Play feature graphics with a centered, aspect-preserving crop.
Add-Type -AssemblyName System.Drawing
foreach ($locale in @('en', 'zh', 'vi')) {
    $source = [System.Drawing.Image]::FromFile((Join-Path $PSScriptRoot "originals/feature-$locale.png"))
    $bitmap = New-Object System.Drawing.Bitmap(1024, 500, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb))
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $cropHeight = $source.Width * 500.0 / 1024.0
        $crop = [System.Drawing.RectangleF]::new(0, (($source.Height - $cropHeight) / 2), $source.Width, $cropHeight)
        $target = [System.Drawing.RectangleF]::new(0, 0, 1024, 500)
        $graphics.DrawImage($source, $target, $crop, [System.Drawing.GraphicsUnit]::Pixel)
        $bitmap.Save((Join-Path $PSScriptRoot "feature-$locale-1024x500.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
        $source.Dispose()
    }
}
