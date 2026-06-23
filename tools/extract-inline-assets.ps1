param(
    [string]$HtmlPath = "index.html",
    [string]$AssetDir = "assets",
    [string]$OutputPath = $HtmlPath
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Resolve-Path $HtmlPath)
$assetPath = Join-Path $root $AssetDir
New-Item -ItemType Directory -Force -Path $assetPath | Out-Null
Get-ChildItem -File -Path $assetPath -Filter "inline-*" | Remove-Item -Force

$html = [IO.File]::ReadAllText((Resolve-Path $HtmlPath))
$pattern = 'data:(?<mime>[^;"'')]+);base64,(?<data>[A-Za-z0-9+/=]+)'
$script:indexByKey = @{}
$script:assetCount = 0

$rewritten = [regex]::Replace($html, $pattern, {
    param($match)

    $mime = $match.Groups["mime"].Value
    $data = $match.Groups["data"].Value
    $key = "$mime|$data"

    if (-not $script:indexByKey.ContainsKey($key)) {
        $extension = switch ($mime) {
            "font/woff2" { "woff2"; break }
            "font/woff" { "woff"; break }
            "font/ttf" { "ttf"; break }
            "application/vnd.ms-fontobject" { "eot"; break }
            "image/svg+xml" { "svg"; break }
            "image/png" { "png"; break }
            "image/jpeg" { "jpg"; break }
            "image/webp" { "webp"; break }
            default { "bin"; break }
        }

        $script:assetCount += 1
        $fileName = "inline-{0:D3}.{1}" -f $script:assetCount, $extension
        $filePath = Join-Path $assetPath $fileName
        [IO.File]::WriteAllBytes($filePath, [Convert]::FromBase64String($data))
        $script:indexByKey[$key] = "$AssetDir/$fileName"
    }

    return $script:indexByKey[$key]
})

$resolvedOutputPath = if ([IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $root $OutputPath }
[IO.File]::WriteAllText($resolvedOutputPath, $rewritten, [Text.UTF8Encoding]::new($false))
Write-Host "Extracted $($script:indexByKey.Count) inline assets to $AssetDir"
Write-Host "Wrote $resolvedOutputPath"
