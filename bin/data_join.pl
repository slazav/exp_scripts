#!/usr/bin/perl

# join a few sets of data with same X values

use strict;
use warnings;

my %val;
my $n=0;
foreach (@ARGV) {
  unless (open IN, $_){
    warn "Can't open $_: $!";
    next;
  }
  while (<IN>){
    my ($v1, @v2) = split(/\s+/, $_);
    my $v2 = join(" ", @v2);
    if ($n==0) {
      $val{$v1} = "$v2";
    }
    else {
      $val{$v1} .= " $v2";
    }
  }
  $n++;
  close IN;
}

foreach (sort {$a<=>$b} keys %val){
  print "$_ $val{$_}\n";
}
