#!/usr/bin/perl -w

use strict;

use utf8;
use open ':std', 'encoding(utf8)';

use Lingua::Stem::Snowball;

my$stemmer = Lingua::Stem::Snowball->new( lang => "es", encoding => "UTF-8"); 
die $@ if $@;

my%stem_to_table = (); # stem => word => count
my%stem_df = (); # stem => document frequencies
my%word_to_stem = (); # word => stem

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

my%stemmed_documents = (); # key => stem => count

foreach my$key(keys %dates){
    my($per,$r)=split(/\-/, $key);
    my$file = "txt/reunion.asp?p=$per&r=$r";
    if( -f $file ) {
	open(F,$file) or die "$file: $!";
	my@t = <F>;
	chomp(@t);
	my%stems_here = ();
	foreach my$l(@t){
	    my@w=split(/\s+|\.|,/,$l);
	    foreach my$w(@w){
		$w=~s/[^a-zA-ZáéíóúüÁÉÍÓÚÜ]+$//;
		$w=~s/^[^a-zA-ZáéíóúüÁÉÍÓÚÜ0-9]+//;
		next unless $w;
		
		my$stem = $word_to_stem{$w};
		if(!defined($stem)){
		    $stem = $stemmer->stem($w);
		    $word_to_stem{$w} = $stem;
		    $stem_to_table{$stem} = {};
		}
		if(defined($stem_to_table{$stem}->{$w})){
		    $stem_to_table{$stem}->{$w}++;
		}else{
		    $stem_to_table{$stem}->{$w}=1;
		}
		$stems_here{$stem}++;
	    }
	}
	foreach my$stem(keys %stems_here){
	    $stem_df{$stem}++;
	}
	$stemmed_documents{$key} = { %stems_here };
    }
}

my%stem_to_word = (); # most common word for stem
foreach my$stem(keys %stem_to_table){
    my%table=%{$stem_to_table{$stem}};
    my$max_word = $stem;
    my$max_count = 0;
    foreach my$word(keys %table){
	my$count = $table{$word};
	if($count > $max_count){
	    $max_word = $word;
	    $max_count = $count;
	}
    }
    $stem_to_word{$stem} = $max_word;
}

my$N = scalar(keys %stemmed_documents) * 1.0;
foreach my$key(keys %stemmed_documents){
    my$date=$dates{$key};
    
    # compute TF*IDF for all stems
    my%document_stems = %{ $stemmed_documents{$key} };

    my@scores=(); # pairs of stem, score
    foreach my$stem(keys %document_stems){
	my$tf = 1.0 + log($document_stems{$stem});
	my$idf = log($N / $stem_df{$stem});
	push@scores, [ $stem, $tf * $idf ];
    }
    my@sorted = sort { $b->[1] <=> $a->[1] } @scores;
    #print "***** $date $key ******\n";
    #foreach my$e(@sorted){
    #	print $e->[0]," ",$e->[1],"\n";
    #}
    my@top = map { $stem_to_word{$_->[0]}."\t".$_->[1] } @sorted[0..19];
    print "$date\t$key\t".join("\t",@top)."\n";
}
