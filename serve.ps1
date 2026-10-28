# Mini static file server for the library (no install needed)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:8341/")
$listener.Start()
Write-Host "Library server running: http://127.0.0.1:8341/"
Write-Host "Root: $root"
Write-Host "Press Ctrl+C to stop."
$mime = @{".html"="text/html; charset=utf-8"; ".js"="text/javascript; charset=utf-8"; ".jpg"="image/jpeg"; ".jpeg"="image/jpeg"; ".png"="image/png"; ".webp"="image/webp"; ".gif"="image/gif"; ".svg"="image/svg+xml"; ".ico"="image/x-icon"}
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
  if ($rel -eq "/") { $rel = "/index.html" }
  $file = Join-Path $root ($rel -replace "/", "\")
  try {
    $full = (Resolve-Path -LiteralPath $file -ErrorAction Stop).Path
    if ($full.StartsWith($root) -and (Test-Path -LiteralPath $file -PathType Leaf)) {
      $bytes = [IO.File]::ReadAllBytes($file)
      $ext = [IO.Path]::GetExtension($file).ToLower()
      if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else { $ctx.Response.StatusCode = 404 }
  } catch { try { $ctx.Response.StatusCode = 404 } catch {} }
  try { $ctx.Response.Close() } catch {}
}
