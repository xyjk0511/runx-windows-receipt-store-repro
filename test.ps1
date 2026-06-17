param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$tmp = Join-Path $root '.tmp'
$npmPrefix = Join-Path $tmp 'npm'
$receiptDir = Join-Path $tmp 'receipts'
$workDir = Join-Path $tmp 'work'
$skillDir = Join-Path $root 'hello-world'

Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $npmPrefix,$receiptDir,$workDir | Out-Null

$env:npm_config_prefix = $npmPrefix
npm install -g @runxhq/cli | Out-Null
$env:Path = "$npmPrefix;$npmPrefix\node_modules\.bin;" + $env:Path

$env:RUNX_RECEIPT_SIGN_KID = 'windows-repro'
$env:RUNX_RECEIPT_SIGN_ED25519_SEED_BASE64 = 'QkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkI='
$env:RUNX_RECEIPT_SIGN_ISSUER_TYPE = 'hosted'

Push-Location $workDir
try {
  $output = & runx skill $skillDir --input 'message=hello' --receipt-dir $receiptDir --json 2>&1
  $exitCode = $LASTEXITCODE
  $output | Set-Content (Join-Path $tmp 'last-output.json')

  if ($exitCode -ne 0) {
    Write-Host 'FAIL: runx skill exited non-zero'
    Write-Host $output
    exit 1
  }

  $receiptFiles = Get-ChildItem -Path $receiptDir -Filter '*.json' -File -ErrorAction SilentlyContinue
  if (-not $receiptFiles -or $receiptFiles.Count -lt 1) {
    Write-Host 'FAIL: no receipt JSON files were created'
    Write-Host $output
    exit 1
  }

  Write-Host 'PASS: receipt-backed run succeeded on Windows'
  exit 0
}
finally {
  Pop-Location
}