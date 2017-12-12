#!/usr/bin/perl

# Join a few sets of data with different X values
# Everything is interpolated to the first file.
# X-values should be sorted.

use strict;
use warnings;

my $data;

############################################
# To be moved in some modules and used everywhere.
# Lines always contain at least one element (nc, number of columns).
# All lines in array have same length.
sub read_file{
  my $fname=shift;
  unless (open IN, $fname){
    warn "Can't open $fname: $!";
    next;
  }
  my $array;

  my $nc = 0;
  while (<IN>){
    # remove comments:
    $_ =~ s/#.*$//;
    # remove empty lines
    next if $_=~/^\s*$/;

    my $val = [split(/\s+/, $_)];
    my $nc1 = $#{$val} + 1;
    next if $nc1 == 0;
    $nc = $nc1 if $nc == 0; # set number of columns
    die "non-uniform number of columns: $fname" if $nc != $nc1;

    #split and add to array
    push @{$array}, [split(/\s+/, $_)];
  }
  close IN;
  return $array;
}
############################################
sub print_array{
  my $array = shift;
  foreach my $line (@{$array}){
    foreach my $val (@{$line}){
      print " $val"
    }
    print "\n";
  }
}
############################################
# add values to a line using some array
sub add_arr_to_line{
  my $l0 = shift;
  my $arr = shift;
  my $x0 = ${$l0}[0];

  my $nc = 0; # number of columns to add
  my $n = 0;  # number of columns added
  # loop through line pairs
  for (my $i=0; $i<$#{$arr}; $i++){
    my $l1 = ${$arr}[$i];
    my $l2 = ${$arr}[$i+1];
    $nc = $#{$l1} if $nc == 0;
    my $x1 = ${$l1}[0];
    my $x2 = ${$l2}[0];
    # if x0 is between x1 and x2 do interpolation
    # end stop looking for other values
    # (note that I use <= and => limits!)
    if (($x1 <= $x0 && $x2 >= $x0) ||
        ($x2 <= $x0 && $x1 >= $x0)) {
      my $w1 = ($x0-$x1)/($x2-$x1);
      for (my $j = 1; $j<=$#{$l1}; $j++){
        my $v1 = ${$l1}[$j];
        my $v2 = ${$l2}[$j];
        push @{$l0}, $v1*$w1 + $v2*(1-$w1);
        $n++;
      }
      last;
    }
  }
  if ($nc > $n) {
    for (my $j=$n; $j<$nc; $j++){
      push @{$l0}, 'nan';
    }
  }

}

############################################

# read all files:
foreach (@ARGV) {
  push @{$data}, read_file($_);
}

# Now go through all arrays 2..end, interpolate and add to the
# first array:

die "not enough data files" if $#{$data} <0;
my $a0 = ${$data}[0];

foreach my $l0 (@{$a0}){
 for (my $i=1; $i<=$#{$data}; $i++){
   add_arr_to_line($l0, ${$data}[$i]);
 }
}

print_array $a0;

