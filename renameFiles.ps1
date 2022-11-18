Param (
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [string]$Source="",
    [Parameter(Position=1)]
    [string]$FileMask="*",
    [Parameter(Position=2)]
    [string]$Dest="",
    [string]$LeadingChar="",
    [switch]$Recurse,
    [switch]$Debug,
    [int]$MaxNumber=99999999
)
$isDebug = $Debug.IsPresent;

if ($Source -eq "") { $Source = ".\"; }
if ($FileMask -eq "") { $FileMask = "*.mp3"; }
if ($Dest -eq "") { $Dest = $Source; }
if ($LeadingChar -eq "") {
    $LeadingChar = (Get-ChildItem ([System.IO.Path]::GetTempFileName())).BaseName + "-";
}

if ($isDebug) {
    echo $LeadingChar
    echo $Source
    echo $srcFiles
    echo $Recurse
}

# вернуть имена файлов в массив
$p = @{
    'Path'= $Source
    'Filter'=$FileMask
    'Recurse'=$Recurse.IsPresent
}
[System.Collections.ArrayList]$files = Get-ChildItem @p

$newFiles = [ordered]@{};
$rv = Get-Random -Minimum 1 -Maximum $MaxNumber;
while ($files.Count -gt 0) {
    while ($newFiles.Contains($rv)) {
        $rv = Get-Random -Minimum 1 -Maximum $MaxNumber;
    }
    $newFiles.Add($rv, $files[0]);
    $files.removeAt(0);
}

$newFiles.Keys.ForEach({
    $f = $newFiles.$_;
    $f.moveTo("$($f.DirectoryName)\$($LeadingChar)$(([string]$_).PadLeft(8,'0'))$($f.Extension)")
});
