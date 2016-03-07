use argola;
use alarmica;
use strict;
my $filen;
my $wordspera = 1;
my $secpera = 9;
my $caff_mode = '-d';
my $wordpcan; # Words per five-second interval:
my $xpecbynow; # Current Word Expectation:
my $timstandr; # Time matching expectation:
my $imediat;
my $bel;
my $wordsare; # Current count of words:
my $wordswere; # Previous count of words:
my $loudness;
my $hstart = 60; # Seconds for initial grace period
my $filefound;
my $dflwordstofull = 2000;
my $wordstofull;
my $wordsatorigin;
my $rate_exp;

my $elaps_source; # The origin time against which all elapsation is measured:
my $elaps_generi; # The current elapsation time:
my $elaps_lstsav; # Elapsation as of last status change:
my $elaps_lggrac; # Last elapsation while in good grace:
my $elaps_lgsave; # Last status change while in good grace:
my $is_grace; # Decabool tells us if we are in good grace:

my $caff_cmdn;

$elaps_source = &alarmica::nowo();
$elaps_generi = $elaps_source;
$elaps_lstsav = $elaps_source;
$elaps_lggrac = $elaps_source;
$elaps_lgsave = $elaps_source;

#$bel = $hme . "/bin-res/morningroutine/snd/tibetan-bell.m4a";
$bel = `chobakwrap -rloc`; chomp($bel);
$bel .= "/sounds/42095__fauxpress__bell-meditation.mp3";

# http://stackoverflow.com/questions/3746947/get-just-the-integer-from-wc-in-bash
sub wcounti {
  my $lc_rt;
  my $lc_cm;
  $ENV{"XX_AKI_XX"} = $_[0];
  
  $lc_rt = 0;
  if ( -f $_[0] )
  {
    $lc_cm = "wc -w < \"\${XX_AKI_XX}\"";
    $lc_cm = "echo \$(" . $lc_cm . ")";
    $lc_rt = `$lc_cm`; chomp($lc_rt);
  }
  return $lc_rt;
}

sub dscrep {
  $imediat = &alarmica::nowo();
  while ( $timstandr < $imediat )
  {
    $xpecbynow += $wordpcan;
    $timstandr = int($timstandr + 5.2);
  }
  #system("echo",$timstandr . " - " . $xpecbynow);
  
  system("clear");
  
  return ( 2 > 1 );
}


$wordstofull = $dflwordstofull;


# No default file, though:
$filefound = 0;




sub opto__f_do {
  $filen = &argola::getrg();
  $filefound = 10;
} &argola::setopt("-f",\&opto__f_do);

sub opto__grc_do {
  $hstart = &argola::getrg();
} &argola::setopt("-grc",\&opto__grc_do);

sub opto__rat_do {
  $wordspera = &argola::getrg();
  $secpera = &argola::getrg();
} &argola::setopt("-rat",\&opto__rat_do);

sub opto__wtl_do {
  $wordstofull = &argola::getrg();
} &argola::setopt("-wtl",\&opto__wtl_do);

sub opto__scr_do {
  $caff_mode = '-d';
} &argola::setopt("-scr",\&opto__scr_do);

sub opto__xscr_do {
  $caff_mode = '-i';
} &argola::setopt("-xscr",\&opto__xscr_do);



&argola::help_opt('--help','help-file.nroff');



&argola::runopts();
if ( $filefound < 5 ) { die "\nwriteontask: FATAL ERROR:\n    No file specified:\n\n"; }




# Assemble the Caffeination Command:
$caff_cmdn = 'caffeinate ' . $caff_mode . ' -t 25';
$caff_cmdn .= ' &bg';
$caff_cmdn = '( ' . $caff_cmdn . ' ) > /dev/null 2> /dev/null';




$rate_exp = $wordspera . " word";
if ( $wordspera != 1 ) { $rate_exp .= "s"; }
$rate_exp .= " every " . $secpera . " second";
if ( $secpera != 1 ) { $rate_exp .= "s"; }

$wordpcan = ( ( $wordspera * 5 ) / $secpera );

$wordsare = &wcounti($filen);
$xpecbynow = $wordsare;

$wordsatorigin = $xpecbynow;
$timstandr = &alarmica::nowo(); $imediat = $timstandr;
if ( $hstart ne "" ) { $timstandr = int($timstandr + $hstart + 0.2); }

while ( $imediat < $timstandr )
{
  my $lc_dif;
  system("clear");
  $lc_dif = int(($timstandr - $imediat) + 0.2);
  system("echo","\n" . $lc_dif . " second(s) remaining in the grace period.");
  &banjora;
  $imediat = &alarmica::nowo();
}


while ( &dscrep ) { &banjora; }
sub banjora {
  my $lc_cm;
  my $lc_lefto;
  my $lc_slptarg;
  
  $lc_slptarg = 2;
  
  # Now we get the next word count:
  $wordswere = $wordsare;
  $wordsare = &wcounti($filen);
  
  # And we get the new generic elapsation:
  $elaps_generi = &alarmica::nowo;
  if ( $wordswere != $wordsare ) { $elaps_lstsav = $elaps_generi; }
  $is_grace = 0;
  
  system("echo");
  system("echo","Our File: " . $filen);
  system("echo");
  system("echo","Target Rate: " . $rate_exp);
  system("echo");
  system("echo","GOAL: " . &oxorig($xpecbynow) . " " . $xpecbynow);
  system("echo","HERE: " . &oxorig($wordsare) . " " . $wordsare);
  
  $lc_lefto = ( 2 > 1 );
  
  if ( $wordsare < $xpecbynow )
  {
    my $lc2_dif;
    $lc2_dif = ( $xpecbynow - $wordsare );
    $loudness = ( $lc2_dif / $wordstofull );
    if ( $loudness > 1 ) { $loudness = 1; } # Let's not go beyond 100% volume:
    system("echo","\nBEHIND BY: " . $lc2_dif);
    system("echo","\nBell volume: " . $loudness);
    $lc_cm = "afplay -v $loudness $bel &bg";
    $lc_cm = "( " . $lc_cm . " ) 2> /dev/null";
    #system("echo",$lc_cm);
    system($lc_cm);
    $lc_slptarg = 5;
    $lc_lefto = ( 1 > 2 );
  }
  
  if ( $wordsare > $xpecbynow )
  {
    my $lc2_dif;
    $lc2_dif = ( $wordsare - $xpecbynow );
    system("echo","\n  ahead by: " . $lc2_dif);
    $lc_lefto = ( 1 > 2 );
    $is_grace = 10;
  }
  
  if ( $lc_lefto ) { system("echo","ON THE CUSP:"); $is_grace = 10; }
  
  
  if ( $is_grace )
  {
    $elaps_lggrac = $elaps_generi;
    if ( $wordswere != $wordsare ) { $elaps_lgsave = $elaps_generi; }
  }
  
  
  system("echo");
  system("echo","                   Time Elapsed So Far: " . &parce_elaps($elaps_generi) . ":");
  system("echo","              As of last status-change: " . &parce_elaps($elaps_lstsav) . ":");
  system("echo","               Last time in good grace: " . &parce_elaps($elaps_lggrac) . ":");
  system("echo","Last status-change while in good grace: " . &parce_elaps($elaps_lgsave) . ":");
  
  
  system($caff_cmdn);
  sleep($lc_slptarg);
}

sub parce_elaps {
  return &alarmica::parcesec(int(($_[0] - $elaps_source) + 0.2));
}


sub oxorig {
  my $lc_src;
  my $lc_chr;
  my $lc_ret;
  my $lc_cnt;
  $lc_src = int(($_[0] - $wordsatorigin) + 0.5);
  $lc_ret = "";
  $lc_cnt = 5;
  while ( $lc_cnt > 0.5 )
  {
    $lc_src = "  " . $lc_src;
    $lc_chr = chop($lc_src);
    $lc_ret = $lc_chr . $lc_ret;
    $lc_cnt = int($lc_cnt - 0.8);
  }
  return $lc_ret;
}
