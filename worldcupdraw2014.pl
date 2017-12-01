#!/usr/bin/perl
use strict;
use Data::Dumper;

my $debug = 1;
my @pot1 = ('Brazil (11)','Spain (1)','Germany (2)','Argentina (3)','Columbia (4)','Belgium (5)','Uruguay (6)','Switzerland (7)');
my @pot2 = ('Chile (12)','Ecuador (22)','Ivory Coast (17)','Ghana (23)','Algeria (32)','Nigeria (33)','Cameroon (59)');
my @pot3 = ('USA (13)','Mexico (24)','Costa Rica (31)','Honduras (34)','Japan (44)','Iran (49)','S Korea (56)','Australia (57)');
my @pot4 = ('Netherlands (8)','Italy (9)','England (10)','Portugal (14)','Greece (15)','Bosnia (16)','Croatia (18)','Russia (19)','France (21)');
my @potx = ();
my %euseeds = ('Spain (1)' => 1,'Germany (2)' => 1,'Belgium (5)' => 1,'Switzerland (7)' =>1);

my @brazarg = ();
my @euarg = ();
my @pots = (\@pot1,\@pot2,\@pot3,\@pot4);
my @groups = ([],[],[],[],[],[],[],[]);

my $first = 1;

#First, Allocate Pot 1
{
	my $i = 0;
	my $len = scalar(@{$pots[$i]});
	my $j = 0;
	while ($j < $len)  {
		my $x;my $y = $j;
		if ($first) {
			# Brazil in group A
			$first = 0;$x = 0
		} else {
			my $l = @{$pots[$i]};
			$x = int(rand($l));
		}
		print "$pots[$i][$x]: " if $debug;
		if ($i == 0 and $j == 0) {
			print " Rule: Brazil is always in Group A ";
		} else {
			print " Rule: pots 1, 2, 3 teams are randomly picked and placed in next group ";
		}
		# Keep track of where Brazil and Argentina And Columbia end up for the pot3
		# processing.
		if ($pots[$i][$x] =~ /Brazil/ or $pots[$i][$x] =~ /Argentina/ or $pots[$i][$x] =~ /Columbia/ or $pots[$i][$x] =~ /Uruguay/  ) {
			push(@brazarg,$y);
		};
		if ($pots[$i][$x] =~ /Spain/ or $pots[$i][$x] =~ /Germany/ or $pots[$i][$x] =~ /Switzerland/ or $pots[$i][$x] =~ /Belgium/  ) {
			push(@euarg,$y);
		};
		print $pots[$i][$x]." is in group $y\n" if $debug;
		push(@{$groups[$y]},$pots[$i][$x]);
		splice(@{$pots[$i]},$x,1,());
		$j++;
	}
}

# Now, get UEFA Team for Pot 2
{
	my $x = int(rand(8));
	my $uefateam = $pots[3][$x];
	print "$uefateam is random UEFA team put drawn with CONMEBOL pot 1 team\n" if $debug;
	splice(@{$pots[3]},$x,1,());
	my $z = int(rand(4));
	my $y = $brazarg[$z];
	print "$uefateam will be placed in Group $y\n" if $debug;
	push(@{$groups[$y]},$uefateam);
}

#Now, get the rest of pot 2

# Cycle over pots
my $conmebolplaced = 0;
for my $i (1..3) {
	# cycle over teams in pots
	my $len = scalar(@{$pots[$i]});
	my $j = 0;
	while ($j < $len)  {
		my $x;my $y = $j;
		my $l = @{$pots[$i]};
		$x = int(rand($l));
		print "$pots[$i][$x]: " if $debug;
		if ($i == 0 and $j == 0) {
		print " Rule: Brazil is always in Group A ";
		# If we're dealing with pot 4, we have to be sure that a CONMEBOL team
		# doesn't end up with Brazil or Argentina or Columbia
		} elsif ($i eq 1) {
			@brazarg = sort(@brazarg);
			@euarg = sort(@euarg);
			my $c = $pots[$i][$x];
			# Yes, I know that there are potential infinite loops in here.  That's why pot 4 is split, and I'm trusting that the randomization 
			#    function will EVENTUALLY find an open slot
			if ($c =~ /Chile/ or $c =~ /Ecuador/ ) {
				#print " Rule: S American teams - Not with Brazil or Argentina Or Columbia, First in Group A " if $debug;
				print " Rule: S American teams - Random group Not with CONMEBOL Seed, " if $debug;
				$y = 0;
				while ($groups[$y][1] or grep $_ == $y, @brazarg) {
					print "Skip $y, " if $debug;
					$y++;
				}
				$conmebolplaced++;
			} else {
				## African Country.   Give it the first open group
				print "Rule: CAF Teams go in first open slots, " if $debug;
				$y = 0;
				while ($groups[$y][1] or ($conmebolplaced < 2 and scalar(keys(%euseeds))<= (2 - $conmebolplaced ) and $euseeds{$groups[$y][0]})) {
					if ($groups[$y][1]) {
						print "Skip $y, taken, " if $debug;
					} else {
						print "Skip $y, save for CONMENBOL team, " if $debug;
					}
					$y++;
				}
				delete $euseeds{$groups[$y][0]};
			}
		} else {
			print " Rule: pots 1, 2, 3 teams are randomly picked and placed in next group ";
		}
		# Keep track of where Brazil and Argentina And Columbia end up for the pot3
		# processing.
		if ($pots[$i][$x] =~ /Brazil/ or $pots[$i][$x] =~ /Argentina/ or $pots[$i][$x] =~ /Columbia/ or $pots[$i][$x] =~ /Uruguay/  ) {
			push(@brazarg,$y);
		};
		if ($pots[$i][$x] =~ /Spain/ or $pots[$i][$x] =~ /Germany/ or $pots[$i][$x] =~ /Switzerland/ or $pots[$i][$x] =~ /Belgium/  ) {
			push(@euarg,$y);
		};
		print $pots[$i][$x]." is in group $y\n" if $debug;
		push(@{$groups[$y]},$pots[$i][$x]);
		splice(@{$pots[$i]},$x,1,());
		$j++;
	}
}

for my $i (0..7) {
	print chr($i+65).":\t";
	for my $j (0..3) {
		print $groups[$i][$j];
		print "," if $j < 3;
	}
	print "\n";
}
exit;


