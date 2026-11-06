@echo off
title Rumo ao Dead God
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=Get-Content -LiteralPath '%~f0' -Raw; iex ($s.Substring($s.IndexOf('#'+'PSSTART')))"
if errorlevel 1 pause
exit /b
#PSSTART
# Le as conquistas da Steam e o save do Isaac (Repentance/Repentance+) e abre o site ja carregado.
# Nada e enviado pra servidor: os arquivos vao compactados no proprio link (#import=...) e sao lidos no navegador.
$ErrorActionPreference = 'Stop'
$site = 'https://joaopraiah.github.io/rumo-ao-dead-god/'

$steam = $null
try { $steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam').SteamPath } catch {}
if (-not $steam) { $steam = Join-Path ${env:ProgramFiles(x86)} 'Steam' }
$steam = $steam -replace '/', '\'
Write-Host "Steam: $steam"

$files = @()
$stats = Join-Path $steam 'appcache\stats'
if (Test-Path $stats) { $files += Get-ChildItem $stats -File | Where-Object { $_.Name -match '^UserGameStats_\d+_250900\.bin$' } }
$userdata = Join-Path $steam 'userdata'
if (Test-Path $userdata) {
  foreach ($u in Get-ChildItem $userdata -Directory) {
    $r = Join-Path $u.FullName '250900\remote'
    if (Test-Path $r) { $files += Get-ChildItem $r -File | Where-Object { $_.Name -match '^rep[+_]persistentgamedata\d\.dat$' } }
  }
}
if ($files.Count -eq 0) {
  Write-Host ''
  Write-Host 'Nao achei nenhum arquivo do Isaac nessa Steam. O jogo ja foi aberto nesse PC?' -ForegroundColor Red
  exit 1
}

$list = foreach ($f in $files) {
  if ($f.Name -match '^UserGameStats_(\d+)_') { $id = $matches[1] } else { $id = $f.Directory.Parent.Parent.Name }
  Write-Host "  + $($f.Name)  (conta $id)"
  [ordered]@{ n = $f.Name; id = $id; t = [long]([DateTimeOffset]$f.LastWriteTimeUtc).ToUnixTimeMilliseconds(); d = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f.FullName)) }
}
$json  = ConvertTo-Json @($list) -Compress
$bytes = [Text.Encoding]::UTF8.GetBytes($json)
$ms = New-Object IO.MemoryStream
$gz = New-Object IO.Compression.GZipStream($ms, [IO.Compression.CompressionMode]::Compress)
$gz.Write($bytes, 0, $bytes.Length); $gz.Close()
$b64 = [Convert]::ToBase64String($ms.ToArray()).TrimEnd('=').Replace('+', '-').Replace('/', '_')

# pagina local que redireciona (evita limite de tamanho de link do Windows)
$html = "<!doctype html><meta charset=utf-8><title>Rumo ao Dead God</title><script>location.replace('$site#import=$b64')</script>Abrindo..."
$tmp = Join-Path $env:TEMP 'rumo-ao-dead-god.html'
[IO.File]::WriteAllText($tmp, $html)
Start-Process $tmp
Write-Host ''
Write-Host 'Pronto! Abrindo o site...' -ForegroundColor Green
Start-Sleep -Seconds 2
