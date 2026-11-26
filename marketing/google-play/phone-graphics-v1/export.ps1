# Keep screenshot content intact: scale proportionally and never redraw app UI.
Add-Type -AssemblyName System.Drawing
$items = @(
    @{ Source = 'drum'; Output = '01-drum-practice'; Title = 'Practice your rhythm'; Subtitle = 'Play, record and save your drum beats.' },
    @{ Source = 'language'; Output = '02-language-options'; Title = 'Choose your language'; Subtitle = 'English, Simplified Chinese and Vietnamese.' },
    @{ Source = 'drum'; Output = '01-drum-practice-vi'; Title = 'Luyện tập nhịp điệu'; Subtitle = 'Đánh trống, ghi âm và lưu lại nhịp trống.' },
    @{ Source = 'language'; Output = '02-language-options-vi'; Title = 'Chọn ngôn ngữ'; Subtitle = 'Tiếng Anh, tiếng Trung giản thể và tiếng Việt.' }
)
$background = [System.Drawing.Image]::FromFile((Join-Path $PSScriptRoot 'sources/background.png'))
$gold = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#D9B975'))
$ivory = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#FFF0D4'))
$muted = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#E4CBB3'))
$brandFont = [System.Drawing.Font]::new('Segoe UI', 25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$titleFont = [System.Drawing.Font]::new('Segoe UI', 68, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bodyFont = [System.Drawing.Font]::new('Segoe UI', 31, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$border = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#A98A55'), 2)
try {
    foreach ($item in $items) {
        $screen = [System.Drawing.Image]::FromFile((Join-Path $PSScriptRoot "sources/$($item.Source).png"))
        $canvas = [System.Drawing.Bitmap]::new(1920, 1080, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
        $g = [System.Drawing.Graphics]::FromImage($canvas)
        try {
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
            $g.DrawImage($background, [System.Drawing.Rectangle]::new(0, 0, 1920, 1080))
            $g.DrawString('Lion Dance Kit', $brandFont, $gold, 70, 38)
            $g.DrawString($item.Title, $titleFont, $ivory, 64, 79)
            $g.DrawString($item.Subtitle, $bodyFont, $muted, 70, 175)
            $scale = [Math]::Min(1780.0 / $screen.Width, 744.0 / $screen.Height)
            $width = [single]($screen.Width * $scale)
            $height = [single]($screen.Height * $scale)
            $left = [single]((1920 - $width) / 2)
            $top = [single](278 + (744 - $height) / 2)
            $g.DrawImage($screen, [System.Drawing.RectangleF]::new($left, $top, $width, $height))
            $g.DrawRectangle($border, $left - 1, $top - 1, $width + 2, $height + 2)
            $canvas.Save((Join-Path $PSScriptRoot "$($item.Output)-1920x1080.png"), [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $g.Dispose()
            $canvas.Dispose()
            $screen.Dispose()
        }
    }
} finally {
    $background.Dispose()
    $gold.Dispose()
    $ivory.Dispose()
    $muted.Dispose()
    $brandFont.Dispose()
    $titleFont.Dispose()
    $bodyFont.Dispose()
    $border.Dispose()
}
