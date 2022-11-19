Param (
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [string]$Source="",
    [Parameter(Position=1)]
    [string]$FileMask="*",
    [Parameter(Position=2)]
    [string]$Dest="",
    [string]$LeadingChar="",
    [switch]$Recurse,
    [switch]$Copy,
    [switch]$isDebug,
    [int]$MaxNumber=99999999
)

if ($Source -eq "") { $Source = ".\"; }
if ($FileMask -eq "") { $FileMask = "*.mp3"; }
if ($Dest -eq "") { $Dest = $Source; }
if ($LeadingChar -eq "") {
    $LeadingChar = (Get-ChildItem ([System.IO.Path]::GetTempFileName())).BaseName + "-";
}

if ($isDebug.IsPresent) {
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
#$files = Get-ChildItem @p
[System.Collections.ArrayList]$files = Get-ChildItem @p
if ($isDebug.IsPresent) {
    echo "files ================================="
    echo $files|select fullname;
    echo "files.count: $($files.count)"
    echo "files.getType: $($files.getType())"
    $files_.ForEach({
        echo $_
    });
}

#exit 0

# подготовить массив с именами в которые скопировать (переименовать)
$newFiles = [ordered]@{};
$rv = Get-Random -Minimum 1 -Maximum $MaxNumber;
while ($files.Count -gt 0) {
    while ($newFiles.Contains($rv)) {
        $rv = Get-Random -Minimum 1 -Maximum $MaxNumber;
    }
    $newFiles.Add($rv, $files[0]);
    $files.removeAt(0);
}
if ($isDebug.IsPresent) {
    echo "newFiles ================================="
    $newFiles;
}

$newFiles.Keys.ForEach({
    if ($isDebug.IsPresent) {
        echo $_;

    }
    $f = $newFiles.$_;
    $f.moveTo("$($f.DirectoryName)\$($LeadingChar)$(([string]$_).PadLeft(8,'0'))$($f.Extension)")
});
