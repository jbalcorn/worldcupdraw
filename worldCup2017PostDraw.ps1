$groups = @()
0..7 | % { $groups += ,($null,$null,$null,$null) }

import-csv wc2018pots.txt | % {
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
        Group = $group
    }
    $groups[[byte][char]$group-65][$pot-1] = $country
}

foreach ($i in 0..7) {
    "Group $([char]($i+65)): $($groups[$i].displayname -join ',')"
}
