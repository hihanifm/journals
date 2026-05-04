# =========================
# Linux-style functions for PowerShell
# =========================

# ---------- Navigation ----------
function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force }
function l { Get-ChildItem }

# Names must be quoted: unquoted .. / ... are operators and break parsing.
function '..' { Set-Location .. }
function '...' { Set-Location ../.. }
function 'cd..' { Set-Location .. }

function pwd { Get-Location }

# ---------- File Operations ----------
function cat { Get-Content }

function touch {
    param($name)
    New-Item -ItemType File -Name $name | Out-Null
}

function cp {
    param($src, $dest)
    Copy-Item -Recurse -Force $src $dest
}

function mv {
    param($src, $dest)
    Move-Item $src $dest
}

function rm {
    param($target)
    Remove-Item -Recurse -Force $target
}

function mkdir {
    param($name)
    New-Item -ItemType Directory -Name $name | Out-Null
}

# ---------- Search ----------
function grep {
    param($pattern, $path=".")
    Get-ChildItem -Recurse -File $path | Select-String $pattern
}

function find {
    param($name, $path=".")
    Get-ChildItem -Recurse -Filter "*$name*" $path
}

# ---------- Process ----------
function ps { Get-Process }

function kill {
    param($id)
    Stop-Process -Id $id
}

function top {
    Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First 20
}

# ---------- Networking ----------
function ifconfig { Get-NetIPAddress }
function ip { Get-NetIPAddress }

function ping {
    # $Host is automatic; do not use $host as a parameter name.
    param([Parameter(Mandatory = $true, Position = 0)][string] $ComputerName)
    Test-Connection $ComputerName
}

# ---------- Git ----------
function gs { git status }
function ga { git add . }

function gc {
    param($msg)
    git commit -m $msg
}

function gp { git push }
function gl { git pull }
function gd { git diff }
function gb { git branch }

function gco {
    param($branch)
    git checkout $branch
}

# ---------- Utilities ----------
function clear { Clear-Host }

function which {
    param($cmd)
    Get-Command $cmd
}

function history { Get-History }

# =========================
# End of file
# =========================
