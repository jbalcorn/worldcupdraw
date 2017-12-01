$pots = @(@(),@(),@(),@())

Import-csv wc2018pots.txt | % {
    $name = $_.name
    $abbr = $_.abbr
    $conf = $_.conf
    $pot = $_.pot

    $country = New-Object -TypeName PSObject -property @{
        Name = $name
        Abbr = $abbr
        Conf = $conf
        Available = $true
    }

    $pots[$pot-1] += $country
}

$groups = @(@(),@(),@(),@(),@(),@(),@(),@())


# POT1. Cannot have a conflict. Russia goes in group A
$i = 0
foreach ($j in 0..7) {
    if ($j -eq 0) {
        $next = $pots[$i] | ? { $_.name -match "Russia" }
        $x = 0
    } else {
        $next = $pots[$i] | ? { $_.Available } | Get-Random
        $Coll = [Collections.Generic.List[Object]]($pots[$i])
        $x = $Coll.FindIndex({ $args[0].name -eq $next.name})
    }
    $groups[$j] += $next
    $pots[$i][$x].Available = $false
    Write-Verbose "$j $($next.name) $($next.conf)"
}

# POT2 - CONMEBOL could cause a conflict. Do those groups first.
$i = 1
$Coll = [Collections.Generic.List[Object]]($pots[$i])
foreach ($j in 0..7) {
    if ($groups[$j].conf -contains "CONMEBOL") {
        $found = $false
        do { 
            $next = $pots[$i] | ? { $_.Available } | Get-Random
            $x = $Coll.FindIndex({ $args[0].name -eq $next.name})
            $c = ($groups[$j].conf | ? { $_ -eq $next.conf } ).count
            if ($c -lt 1) {
                $groups[$j] += $next
                $pots[$i][$x].Available = $false
                Write-Verbose "$j $($next.name) $($next.conf)"
                $found = $true
            } else {
                Write-Verbose "Rejecting $($next.name) in group $j"
            }
        } until ($found)
    }
}

# Still POT2 - now the UEFA ones
# No chance of a conflict, we can have up to 2 UEFA and we've already done CONMEBOL        
foreach ($j in 0..7) {
    if ($groups[$j].count -eq 1) {
        $next = $pots[$i] | ? { $_.Available } | Get-Random
        $x = $Coll.FindIndex({ $args[0].name -eq $next.name})
        $groups[$j] += $next
        $pots[$i][$x].Available = $false
        Write-Verbose "$j $($next.name) $($next.conf)"
    }
}

# POT3 - Place any with UEFAx2 and Mexico first. No CONMEBOL in pot3 so no chance of conflict.

$i = 2
$Coll = [Collections.Generic.List[Object]]($pots[$i])
foreach ($j in 0..7) {
    if ( ($groups[$j].conf | ? {$_ -eq "UEFA" }).count -eq 2 -or ($groups[$j].conf | ? {$_ -eq "CONCACAF" }).count -eq 1 ) {
        $found = $false
        do { 
            $next = $pots[$i] | ? { $_.Available } | Get-Random
            $x = $Coll.FindIndex({ $args[0].name -eq $next.name})
            if ($next.conf -eq "UEFA") {
                $max = 2
            } else {
                $max = 1
            }
            $c = ($groups[$j].conf | ? { $_ -eq $next.conf } ).count
            if ($c -lt $max) {
                $groups[$j] += $next
                $pots[$i][$x].Available = $false
                Write-Verbose "$j $($next.name) $($next.conf)"
                $found = $true
            } else {
                Write-Verbose "Rejecting $($next.name) in group $j"
            }
        } until ($found)
    }
}

# Rest of POT 3 - No conflict chances
foreach ($j in 0..7) {
    if ($groups[$j].count -eq 2) {
        $next = $pots[$i] | ? { $_.Available } | Get-Random
        $x = $Coll.FindIndex({ $args[0].name -eq $next.name})
        $groups[$j] += $next
        $pots[$i][$x].Available = $false
        Write-Verbose "$j $($next.name) $($next.conf)"
    }
}

# POT4 - Keep track of number of slots available for each confederation and if we get down to a last slot for a confederation, put that one there.
$i = 3
$Coll = [Collections.Generic.List[Object]]($pots[$i])
$groupsopen = @(@(),@(),@(),@(),@(),@(),@(),@())
$count = 0
foreach ($x in 0..7) {
    if (($groups[$x] | ? { $_.conf -eq "UEFA" }).count -lt 2) {
        $groupsopen[$x] += "UEFA"
        $count++
    }
}
foreach ($x in 0..7) {
    if (-Not ($groups[$x] | ? { $_.conf -eq "AFC" })) {
        $groupsopen[$x] += "AFC"
    }
}
foreach ($x in 0..7) {
    if (-Not ($groups[$x] | ? { $_.conf -eq "CAF" })) {
        $groupsopen[$x] += "CAF"
    }
}
foreach ($x in 0..7) {
    if (-Not ($groups[$x] | ? { $_.conf -eq "CONCACAF" })) {
        $groupsopen[$x] += "CONCACAF"
    }
}

$slots = @{ "AFC" = 7; "CAF" = 5; "CONCACAF" = 6; "UEFA" = $count }
$teams = @{ "AFC" = 4; "CAF" = 2; "CONCACAF" = 1; "UEFA" = 1 }
foreach ($j in 0..7) {
    # First find out if we have a team that MUST be placed
    $confseligible = $groupsopen[$j]
    foreach ($conf in $groupsopen[$j]) {
        if ($teams[$conf] -eq $slots[$conf]) {
            Write-Verbose "Must choose $conf team for group $j"
            $confseligible =  $conf
        }
    }
    $next = $pots[$i] | ? { $_.Available } | ? {  ($confseligible -contains $_.conf) } | Get-Random
    $x = $Coll.FindIndex({ $args[0].name -eq $next.name})
    $teams[$($next.conf)]--
    foreach ($conf in $groupsopen[$j]) {
        $slots[$conf]--
    } 
    $groups[$j] += $next
    $pots[$i][$x].Available = $false
    Write-Verbose "$j $($next.name) $($next.conf)"
}


foreach ($i in 0..7) {
    "Group $([char]($i+65)): $($groups[$i].name -join ',')"
}