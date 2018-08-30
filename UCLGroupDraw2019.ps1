<# 
   .Synopsis 
    UCLGroupDraw2019.ps1 - 2018 World Cup Draw Simulator  
   .Example 
    UCLGroupDraw2019.ps1
    
    This will read the list of pots and simulate a possible World Cup draw
   .Example
    UCLGroupDraw2019.ps1 -postdraw

    This will just print the groups as they were drawn on Dec 1, 2017, if you have the Group column on the input file.
   .Notes 
    NAME: UCLGroupDraw2019.ps1
    AUTHOR: Justin B. Alcorn
    LASTEDIT: 8/29/2018
    KEYWORDS: #UCLDraw
#> 
Param(
    [switch]$postdraw
)

$rules = @{ "Assocs" = @() }

$pots = @(@(), @(), @(), @())
if ($postdraw) {
    $groups = @()
    0..7 | % { $groups += , ($null, $null, $null, $null) }
}


Import-csv uclgroupdraw2019.txt -Encoding UTF8 | % {
    $name = $_.team
    $pot = $_.pot
    $assoc = $_.assoc
    $group = $_.group

    $team = New-Object -TypeName PSObject -property @{
        Name      = $name
        Assoc     = $assoc
        Available = $true
    }

    $pots[$pot - 1] += $team
    $rules["Assocs"] += $assoc
    if ($postdraw) {
        $groups[[byte][char]$group - 65][$pot - 1] = $team
    }
}
$Rules["Assocs"] = $rules["Assocs"] | Select-Object -Unique
if (-Not $postdraw) {
    $groups = @(@(), @(), @(), @(), @(), @(), @(), @())
    foreach ($i in 0..3) {
        $Coll = [Collections.Generic.List[Object]]($pots[$i])
        $groupsopen = @(@(), @(), @(), @(), @(), @(), @(), @())
        $slots = @{}
        foreach ($x in 0..7) {
            if ($groups[$i]) {
                $assocsopen[$x] = Compare-Object $groups[$x].Assoc $Rules["Assocs"] -passthru
            }
            else {
                $assocsopen[$x] = $Rules["Assocs"]
            }
            foreach ($assoc in $assocsopen[$x]) {
                $slots[$assoc]++
            }
        }
        $teams = @{}
        foreach ($team in $pots[$i]) {
            $teams[$($team.assoc)]++
        }
        foreach ($j in 0..7) {
            $assocseligible = $assocsopen[$j]
            ##
            # Choose a random team from the Available teams in the Eligible Assoc
            ##
            $next = $pots[$i] | ? { $_.Available } | ? {  ($assocseligible -contains $_.assoc) } | Get-Random
            if (! $next) {
                Write-Host "no Next"
            }
            $x = $Coll.FindIndex( { $args[0].name -eq $next.name})
            $teams[$($next.assoc)]--
            $groups[$j] += $next
            $pots[$i][$x].Available = $false
            Write-Verbose "$j $($next.name) $($next.conf)"
        }
    }
}

foreach ($i in 0..7) {
    Write-Host "Group $([char]($i+65)): $($groups[$i].name -join ',')" 
}
