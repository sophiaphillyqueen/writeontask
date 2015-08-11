use argola;
use strict;
my $filen;
my $wordspera;
my $secpera;
my $wordpcan; # Words per five-second interval:
my $xpecbynow; # Current Word Expectation:
my $timstandr; # Time matching expectation:
my $imediat;
my $bel;
my $wordsare;
my $loudness;
my $hstart;
my $filefound;
my $wordstofull;

#$bel = $hme . "/bin-res/morningroutine/snd/tibetan-bell.m4a";
$bel = &argola::srcd;
$bel .= "/sounds/42095__fauxpress__bell-meditation.mp3";

# http://stackoverflow.com/questions/3746947/get-just-the-integer-from-wc-in-bash
sub wcounti {
  my $lc_rt;
  my $lc_cm;
  $ENV{"XX_AKI_XX"} = $_[0];
  
  $lc_cm = "wc -w < \"\${XX_AKI_XX}\"";
  $lc_cm = "echo \$(" . $lc_cm . ")";
  
  $lc_rt = `$lc_cm`; chomp($lc_rt);
  return $lc_rt;
}

sub nowo {
  my $lc_a;
  $lc_a = `date +%s`;
  chomp($lc_a);
  return $lc_a;
}

sub dscrep {
  $imediat = &nowo;
  while ( $timstandr < $imediat )
  {
    $xpecbynow += $wordpcan;
    $timstandr = int($timstandr + 5.2);
  }
  #system("echo",$timstandr . " - " . $xpecbynow);
  $wordsare = &wcounti($filen);
  
  system("echo");
  system("echo","GOAL: " . $xpecbynow);
  system("echo","HERE: " . $wordsare);
  
  
  return ( 2 > 1 );
}

#($wordspera,$secpera,$hstart,$filen) = @ARGV;
# Let us now set up the defaults

# One word every six seconds = default goal
$wordspera = 1;
$secpera = 6;

$wordstofull = 6000;

# 20 seconds head-start by default
$hstart = 20;
$hstart = 0;

# No default file, though:
$filefound = 0;




sub opto__f_do {
  $filen = &argola::getrg;
  $filefound = 10;
} &argola::setopt("-f",\&opto__f_do);

&argola::runopts;
if ( $filefound < 5 ) { die "\nwriteontask: FATAL ERROR:\n    No file specified:\n\n"; }

$wordpcan = ( ( $wordspera * 5 ) / $secpera );

$xpecbynow = &wcounti($filen);
$timstandr = &nowo;
if ( $hstart ne "" ) { $timstandr = int($timstandr + $hstart + 0.2); }
while ( &dscrep )
{
  my $lc_cm;
  if ( $wordsare < $xpecbynow )
  {
    $loudness = ( ( $xpecbynow - $wordsare ) / $wordstofull );
    if ( $loudness > 1 ) { $loudness = 1; } # Let's not go beyond 100% volume:
    $lc_cm = "afplay -v $loudness $bel &bg";
    $lc_cm = "( " . $lc_cm . " ) 2> /dev/null";
    #system("echo",$lc_cm);
    system($lc_cm);
    sleep(3);
  }
  sleep(2);
}