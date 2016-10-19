#!/usr/bin/perl -w

use strict;

use utf8;
use open ':std', 'encoding(utf8)';

open(D,"dates.tsv") or die"dates: $!";
my@dates=<D>;
chomp@dates;
my%dates = map { chomp; 
		 my@p=split(/\t/,$_);
		 $p[0]=~ s/\&r=/-/;
		 my@d=split(/\//, $p[1]);
		 $p[0] => "$d[2]$d[1]$d[0]"
               } @dates;
close D;

my%tables = ();

foreach my$key(keys %dates){
    my($per,$r)=split(/\-/, $key);
    my$file = "tablas_asistencia_gender/asistencia.asp?per=$per&reunion=$r";
    if( -f $file ) {
	open(F,$file) or die "$file: $!";
	my@t = <F>;
	chomp(@t);
	$tables{$key} = { map { my@g=split(/\t/,$_); $g[0] => [ 0, $g[1] ] } @t };
    }
}

while(<STDIN>){
    my($file,$names,$etc)=split(/\t/, $_);
    my($per,$r)=$file=~ m/reunion.asp\?p=(\d+)&r=(\d+)/;
    my$key = "$per-$r";
    next unless $tables{$key};
    my$table = $tables{$key};
    my@names=split(/,\s*/,$names);
    foreach my$name(@names){
	my@parts = split(/\s+/, $name);

	foreach my$existing_name(keys %{$table}){
	    # determine how likely it is that name is existing name

	    my($last_name, $given_names) = split(/\,\s*/, $existing_name);
	    my@given_names = split(/\s+/,$given_names);

	    my$score = 0;

	    if(index($name, $last_name)>= 0){
		$score += 0.5;
	    }
	    foreach my$given_name(@given_names){
		if(index($name, $given_name)>=0){
		    $score += 0.2;
		}
	    }
	    $table->{$existing_name}->[0] += $score;
	}
    }
}

foreach my$key(keys %tables){
    my$m=0;
    my$f=0;
    my$M=0;
    my$F=0;
    my$table=$tables{$key};
    my$date=$dates{$key};

    foreach my$person(keys %{$table}){
	if($table->{$person}->[0] > 0.5){
	    # person was mentioned or spoke
	    if($table->{$person}->[1] eq "f"){
		$f++;
	    }else{
		$m++;
	    }
	}
	if($table->{$person}->[1] eq "f"){
	    $F++;
	}else{
	    $M++;
	}
    }
    print "$date\t$m\t$f\t$M\t$F\n";
}

