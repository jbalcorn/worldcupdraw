<# 
   .Synopsis 
    worldCup2018.ps1 - 2018 World Cup Draw Simulator  
   .Example 
    worldcup2018.ps1
    
    This will read the list of pots and simulate a possible World Cup draw
   .Example
    worldCup2018.ps1 -postdraw

    This will just print the groups as they were drawn on Dec 1, 2017, if you have the Group column on the input file.
   .Notes 
    NAME: worldCup2018.ps1
    AUTHOR: Justin B. Alcorn
    LASTEDIT: 12/01/2017 17:49:35 
    KEYWORDS: #WorldCupDraw
#> 
Param(
    [switch]$postdraw
)

$rules = @{
    "UEFA" = @{"max" = 2};
    "CONMEBOL" = @{"max" = 1};
    "CONCACAF" = @{"max" = 1};
    "CAF" = @{"max" = 1};
    "AFC" = @{"max" = 1}  
}

$pots = @(@(),@(),@(),@())
if ($postdraw) {
    $groups = @()
    0..7 | % { $groups += ,($null,$null,$null,$null) }
}


Import-csv wc2018pots.txt | % {
    $name = $_.name
    $rank = $_.rank
    $displayname = "$($_.name) ($($rank))"
    $abbr = $_.abbr
    $conf = $_.conf
    $pot = $_.pot
    $group = $_.group

    $country = New-Object -TypeName PSObject -property @{
        DisplayName = $displayname
        Name = $name
        Abbr = $abbr
        Conf = $conf
        Rank = $rank
        Available = $true
    }

    $pots[$pot-1] += $country
    if ($postdraw) {
        $groups[[byte][char]$group-65][$pot-1] = $country
    }
}

if (-Not $postdraw) {
$groups = @(@(),@(),@(),@(),@(),@(),@(),@())
foreach ($i in 0..3) {
    $Coll = [Collections.Generic.List[Object]]($pots[$i])
    $groupsopen = @(@(),@(),@(),@(),@(),@(),@(),@())
    $slots = @{}
    foreach ($conf in $rules.keys) {
        foreach ($x in 0..7) {
            if (@(($groups[$x] | ? { $_.conf -eq $conf })).count -lt ($rules[$conf]).max) {
                $groupsopen[$x] += $conf
                $slots[$conf]++
            }
        }
    }
    $teams = @{}
    foreach ($team in $pots[$i]) {
        $teams[$($team.conf)]++
    }
    foreach ($j in 0..7) {
        ####
        # Choose the next team to place
        # Host country goes in Pot 1 Group A
        if ($i -eq 0 -and $j -eq 0) {
            $next = $pots[$i] | ? { $_.name -match "Russia" }
        } else {
            #
            # Find out if we have a team that MUST be placed because of rules
            #  Note that Group 7 will always hit this code, which is fine, because there is only one Available team anyway
            #
            $confseligible = $groupsopen[$j]
            foreach ($conf in $groupsopen[$j]) {
                if ($teams[$conf] -eq $slots[$conf]) {
                    Write-Verbose "Must choose $conf team for group $j"
                    $confseligible =  $conf
                }
            }
            ##
            # Choose a random team from the Available teams in the Eligible Conference.
            ##
            $next = $pots[$i] | ? { $_.Available } | ? {  ($confseligible -contains $_.conf) } | Get-Random
            ####
            # Code inserted by Russian Hackers. Removed too late.
            #   if ($j -eq 0) {
            #      $next = $pots[$i] | Select-object -Last 2 | Get-Random
            #    }
        }
        $x = $Coll.FindIndex({ $args[0].name -eq $next.name})
        $teams[$($next.conf)]--
        foreach ($conf in $groupsopen[$j]) {
            $slots[$conf]--
        } 
        $groups[$j] += $next
        $pots[$i][$x].Available = $false
        Write-Verbose "$j $($next.name) $($next.conf)"
    }
}
}

foreach ($i in 0..7) {
    "Group $([char]($i+65)): $($groups[$i].displayname -join ',')"
}
