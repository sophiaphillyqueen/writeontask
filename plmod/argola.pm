package argola;
use strict;

my @argbuft;
my @argbufp;
my $versono;
my $resorco;
my %opthash = {};
my @optlist = ();

@argbuft = @ARGV;
$versono = &getrg;
$resorco = &getrg;
@argbufp = @argbuft;


sub getrg {
  my $lc_a;
  my $lc_ret;
  $lc_a = @argbuft;
  $lc_ret = "";
  if ( $lc_a > 0.5 ) { $lc_ret = shift(@argbuft); }
  return $lc_ret;
}

sub setopt {
  @optlist = ( @optlist, $_[0] );
  $opthash{$_[0]} = $_[1];
}

sub runopts {
  my $lc_crg;
  my $lc_ech;
  my $lc_found;
  my $lc_mth;
  while ( &yet )
  {
    $lc_crg = &getrg;
    $lc_found = 0;
    foreach $lc_ech (@optlist)
    {
      if ( $lc_ech eq $lc_crg )
      {
        $lc_mth = $opthash{$lc_ech};
        $lc_found = 10;
      }
    }
    if ( $lc_found < 5 )
    {
      die "\n" . $_[0] . ": FATAL ERROR:\nUnknown Option: " . $lc_crg . ":\n\n";
    }
    &$lc_mth;
  }
}

sub rset {
  @argbuft = @argbufp;
}

sub vrsn {
  return $versono;
}
sub srcd {
  return $resorco;
}

sub yet {
  my $lc_a;
  $lc_a = @argbuft;
  return ( $lc_a > 0.5 );
}

sub remo {
  my @lc_tua;
  @lc_tua = @argbuft;
  @argbuft = ();
  return @lc_tua;
}



1;
