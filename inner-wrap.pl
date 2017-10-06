use argola;
use alarmica;
use strict;
use wraprg;
use chobaktime;
use Scalar::Util qw(looks_like_number);
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
my $vibradurmax = 4000;
my $vibradurati = ( 1000 * 100 );
my $vibra_hide = 10;
my $start_ahead = 'x';
my @extops = ();
my @shcmx = ();

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

sub opto__grcms_do {
  $hstart = &argola::getrg();
  $hstart = int( ( 60 * $hstart ) + &argola::getrg() + 0.2 );
} &argola::setopt("-grcms",\&opto__grcms_do);

sub opto__rat_do {
  $wordspera = &argola::getrg();
  $secpera = &argola::getrg();
} &argola::setopt("-rat",\&opto__rat_do);

sub otpo__shcm_do {
  @shcmx = (@shcmx,&argola::getrg());
} &argola::setopt("-shcm",\&otpo__shcm_do);

sub opto__wtl_do {
  $wordstofull = &argola::getrg();
} &argola::setopt("-wtl",\&opto__wtl_do);

sub opto__vib_do {
  $vibradurati = $vibradurmax;
  @extops = (@extops,'-nomin');
} &argola::setopt('-vib',\&opto__vib_do);

sub opto__vwtl_do {
  &opto_vib_do();
  &opto_wtl_do();
} &argola::setopt('-vwtl',\&opto__vwtl_do);

sub opto__scr_do {
  $caff_mode = '-d';
} &argola::setopt("-scr",\&opto__scr_do);

sub opto__xscr_do {
  $caff_mode = '-i';
} &argola::setopt("-xscr",\&opto__xscr_do);

sub opto__nbgv_do {
  $vibra_hide = 0;
} &argola::setopt('-nbgv',\&opto__nbgv_do);

sub opto__sah_do {
  my $lc_argo;
  $lc_argo = &argola::getrg();
  if ( !(looks_like_number($lc_argo)) )
  {
    die "\nwriteontask: FATAL ERROR: -sah must be followed by a number as it's argument.\n\n";
  }
  $start_ahead = $lc_argo;
} &argola::setopt('-sah',\&opto__sah_do);



&argola::help_opt('--help','help-file.nroff');



&argola::runopts();
if ( $filefound < 5 ) { die "\nwriteontask: FATAL ERROR:\n    No file specified:\n\n"; }




# Assemble the Caffeination Command:
$caff_cmdn = 'caffeinate ' . $caff_mode . ' -t 25';
$caff_cmdn .= ' &bg';
$caff_cmdn = '( ' . $caff_cmdn . ' ) > /dev/null 2> /dev/null';


sub act_on_shcm {
  my $lc_a;
  foreach $lc_a (@shcmx) { system($lc_a); }
}



sub represecs {
  my $lc_a;
  my $lc_b;
  
  $lc_a = int($_[0] + 0.4);
  $lc_b = &chobaktime::tsubdv($lc_a,60,2);
  $lc_b = &chobaktime::tsubdv($lc_a,60,2) . ':' . $lc_b;
  $lc_b = $lc_a . ':' . $lc_b;
  return $lc_b;
}


$rate_exp = $wordspera . " word";
if ( $wordspera != 1 ) { $rate_exp .= "s"; }
$rate_exp .= " every " . $secpera . " second";
if ( $secpera != 1 ) { $rate_exp .= "s"; }

$wordpcan = ( ( $wordspera * 5 ) / $secpera );

&act_on_shcm();
$wordsare = &wcounti($filen);
$xpecbynow = $wordsare;
if ( $start_ahead ne 'x' )
{
  $xpecbynow = 0;
  if ( $wordsare > $start_ahead )
  {
    $xpecbynow = int(($wordsare - $start_ahead) + 0.2);
  }
}

$wordsatorigin = $xpecbynow;
$timstandr = &alarmica::nowo(); $imediat = $timstandr;
if ( $hstart ne "" ) { $timstandr = int($timstandr + $hstart + 0.2); }

while ( $imediat < $timstandr )
{
  my $lc_dif;
  my $lc_disp;
  my $lc_dsa;
  
  system("clear");
  $lc_dif = int(($timstandr - $imediat) + 0.2);
  
  $lc_dsa = $lc_dif;
  $lc_disp = &chobaktime::tsubdv($lc_dsa,60,2);
  $lc_disp = &chobaktime::tsubdv($lc_dsa,60,2) . ':' . $lc_disp;
  $lc_disp = $lc_dsa . ':' . $lc_disp;
  
  system("echo","\n" . $lc_disp . " remaining in the grace period.");
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
  &act_on_shcm();
  $wordsare = &wcounti($filen);
  
  # And we get the new generic elapsation:
  $elaps_generi = &alarmica::nowo;
  if ( $wordswere != $wordsare ) { $elaps_lstsav = $elaps_generi; }
  $is_grace = 0;
  
  system("echo");
  system("echo","Our File: " . $filen);
  system("echo");
  system("echo","Target Rate: " . $rate_exp . ' (Original Grace period: ' . &represecs($hstart) . ')');
  system("echo");
  system("echo","GOAL: " . &oxorig($xpecbynow) . " " . $xpecbynow);
  system("echo","HERE: " . &oxorig($wordsare) . " " . $wordsare);
  
  $lc_lefto = ( 2 > 1 );
  
  if ( $wordsare < $xpecbynow )
  {
    my $lc2_dif;
    my $lc2_cm;
    my $lc2_ld;
    $lc2_dif = ( $xpecbynow - $wordsare );
    $loudness = ( $lc2_dif / $wordstofull );
    if ( $loudness > 1 ) { $loudness = 1; } # Let's not go beyond 100% volume:
    system("echo","\nBEHIND BY: " . $lc2_dif);
    system("echo","\nBell volume: " . $loudness);
    #$lc_cm = "afplay -v $loudness $bel";

    $lc_cm = "chobakwrap-sound -vol $loudness -snd $bel";

    $lc_cm .= " &bg";
    $lc_cm = "( " . $lc_cm . " ) > /dev/null 2> /dev/null";
    #$lc_cm = "echo " . $lc_cm;

    #system("echo",$lc_cm);
    system($lc_cm);
    $lc_slptarg = 5;
    $lc_lefto = ( 1 > 2 );
    
    # And now --- for the good vibrations:
    $lc2_ld = int($loudness * $vibradurati);
    if ( $lc2_ld > $vibradurmax ) { $lc2_ld = $vibradurmax; }
    
    $lc2_cm = 'chobakwrap-para-vibrate -msec ' . $lc2_ld;
    &wraprg::lst($lc2_cm,@extops);
    if ( $vibra_hide > 5 ) { $lc2_cm = '( ' . $lc2_cm . ' &bg ) > /dev/null 2> /dev/null'; }
    system($lc2_cm);
  }
  
  if ( $wordsare > $xpecbynow )
  {
    my $lc2_dif;
    my $lc2_repres;
    $lc2_dif = ( $wordsare - $xpecbynow );
    
    $lc2_repres = represecs(($lc2_dif * $secpera) / $wordspera);
    
    system("echo","\n  ahead by: " . $lc2_dif . ' (' . $lc2_repres . ')');
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
