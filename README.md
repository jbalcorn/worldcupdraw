# worldcupdraw
If FIFA needs code to complete the WC draw....

In 2010 I wrote a perl script to create WC Groups based on FIFA's pots and rules. I updated it in 2014, where the creation rules got REALLY interesting...

In 2018 I decided to rewrite it in PowerShell and discovered that the non-geographic pots made the code REALLY difficult.  9 hours of work finally came up with code the correctly creates legal, random groups every time.

Example run:

PS C:\Users\jalcorn> $VerbosePreference = "Continue"
PS C:\Users\jalcorn> C:\Users\jalcorn\worldCup2018.ps1
VERBOSE: 0 Russia (65) UEFA
VERBOSE: 1 Belgium (5) UEFA
VERBOSE: 2 Poland (6) UEFA
VERBOSE: 3 Portugal (3) UEFA
VERBOSE: 4 Argentina (4) CONMEBOL
VERBOSE: 5 France (7) UEFA
VERBOSE: 6 Germany (1) UEFA
VERBOSE: 7 Brazil (2) CONMEBOL
VERBOSE: 4 England (12) UEFA
VERBOSE: Rejecting Peru (10) in group 7
VERBOSE: 7 Spain (8) UEFA
VERBOSE: 0 Croatia (18) UEFA
VERBOSE: 1 Uruguay (17) CONMEBOL
VERBOSE: 2 Columbia (13) CONMEBOL
VERBOSE: 3 Mexico (16) CONCACAF
VERBOSE: 5 Switzerland (11) UEFA
VERBOSE: 6 Peru (10) CONMEBOL
VERBOSE: Rejecting Denmark (19) in group 0
VERBOSE: 0 Iran (24) AFC
VERBOSE: 3 Sweden (25) UEFA
VERBOSE: 5 Egypt (30) CAF
VERBOSE: 1 Costa Rica (22) CONCACAF
VERBOSE: 2 Denmark (19) UEFA
VERBOSE: 4 Iceland (21) UEFA
VERBOSE: 6 Tunisia (28) CAF
VERBOSE: 7 Senegal (32) CAF
VERBOSE: 0 Panama (49) CONCACAF
VERBOSE: 1 South Korea (62) AFC
VERBOSE: 2 Morocco (48) CAF
VERBOSE: 3 Nigeria (41) CAF
VERBOSE: 4 Japan (44) AFC
VERBOSE: 5 Saudi Arabia (63) AFC
VERBOSE: 6 Australia (43) AFC
VERBOSE: Must choose UEFA team for group 7
VERBOSE: 7 Serbia (38) UEFA
Group A: Russia (65),Croatia (18),Iran (24),Panama (49)
Group B: Belgium (5),Uruguay (17),Costa Rica (22),South Korea (62)
Group C: Poland (6),Columbia (13),Denmark (19),Morocco (48)
Group D: Portugal (3),Mexico (16),Sweden (25),Nigeria (41)
Group E: Argentina (4),England (12),Iceland (21),Japan (44)
Group F: France (7),Switzerland (11),Egypt (30),Saudi Arabia (63)
Group G: Germany (1),Peru (10),Tunisia (28),Australia (43)
Group H: Brazil (2),Spain (8),Senegal (32),Serbia (38)
