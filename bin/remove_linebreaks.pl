#!/usr/bin/perl 
#Script to cleanup plain text by removing hard line breaks,
#ensuring single spaces between sentences, 
#and replacing double hypens with true em dashes (—).
#Recommended usage is with filehandle redirects, e.g.:
#`remove_whitespace.pl <infile >outfile` or simply with pipes

use strict;
use warnings;
use diagnostics;
use feature qw/switch say/; 
use Term::ANSIColor; #Allows for bolding of title output;
use Getopt::Std; #Allow parsing of command-line options;

my %Options=(); #Create scalar for command-line options;
getopts('f:n:', \%Options); #This style of grabbing doesn't support flag arguments, just flags
my $format = $Options{f} || 0; #get value for 'format' flag; 
my $paragraph_count = $Options{n}; #get value for total number of paragraphs to print: 

local $/ = ''; #This allows for reading into a string as a paragraph;
my @paragraphs = <STDIN>; #get input data to modify, as paragraph strings;

sub cleanup_paragraph { #make ugly text readable;
    #####BEGIN text-processing;
    my $raw_text = shift; #grab text to process from function caller;
    $raw_text =~ s/\n+/ /gs; #remove all hard line breaks;
    $raw_text =~ s/[^\S\n]+/ /gs; #remove multiple instances of whitespace, such as double-spacing between sentences;
    $raw_text =~ s/-{2}/—/g; #replace ugly double hyphens with a real em dash;
    $raw_text =~ s/\\"/'/g; #remove escaped quotes, because sadly sometimes that happens;
    chomp $raw_text; #remove excessive newlines;
    return $raw_text; #pass back prettier text to function caller;
    #####END text-processing;
}

sub print_standard { #print processed paragraph as normal text;
    my $paragraph_count = shift; #unpack number of paragraphs to print, if given;
    my $counter = 0; #initialize counter, to support control of number of paragraphs printed;

    foreach my $paragraph (@paragraphs) { #look at each paragraph in list;
        my $entry = cleanup_paragraph($paragraph); #call paragraph cleaner, store result;
        say $entry; #say entry, which is now cleanly formatted;

        if (defined($paragraph_count)) { #only do this if a value exists for $paragraph_count;
            $counter++; #increment our counter, because a paragrpah has been printed;
            last if $counter == $paragraph_count; #stop if desired number of paragraphs have been printed;
        }
    }
}

sub print_titled { #print processed paragraphs with first-line titles in bold;
    my $paragraph_count = shift; #unpack number of paragraphs to print, if given;
    my $counter = 0; #initialize counter, to support control of number of paragraphs printed;

    foreach my $paragraph (@paragraphs) { #look at each paragraph in list;
        $paragraph =~ m/(\s+)(.*)(\n)/; #search for first non-whitespace word-characters;
        my $title = $2; #name matched group above;
        chomp $title; #remove any trailing newlines, can't be too careful;
        print color 'bold'; #Make next text be printed bold;
        say $title; #say title, which will appear bold;
        print color 'reset'; #make next text be printed normally, not bold;
        my $entry = cleanup_paragraph($paragraph); #call paragraph cleaner, store result;
        $entry =~ s/^\s+$title//; #remove first occurrence of title;
        say $entry; #say entry, which is now cleanly formatted;

        if (defined($paragraph_count)) { #only do this if a value exists for $paragraph_count;
            $counter++; #increment our counter, because a paragrpah has been printed;
            last if $counter == $paragraph_count; #stop if desired number of paragraphs have been printed;
        }
    }
}
sub print_coarse { 
    my $paragraph_count = shift; #unpack number of paragraphs to print, if given;
    my $counter = 0; #initialize counter, to support control of number of paragraphs printed;

    foreach my $paragraph (@paragraphs) { #look at each paragraph in list;
        chomp $paragraph;
        say $paragraph;

        if (defined($paragraph_count)) { #only do this if a value exists for $paragraph_count;
            $counter++; #increment our counter, because a paragrpah has been printed;
            last if $counter == $paragraph_count; #stop if desired number of paragraphs have been printed;
        }
    }
}

given ($format) {
    when (/t/)      { print_titled($paragraph_count) }
    when (/c/)      { print_coarse($paragraph_count) }
    when (/s/)      { print_standard($paragraph_count) }
    default         { print_standard($paragraph_count) }
}
#$titled >= 1 #check whether title option is declared;
#    ? print_titled #if so, print with title highlighting;
#    : print_standard; #if not, print normally;
#$coarse >= 1 #check whether title option is declared;
#    ? print_coarse #if so, print with title highlighting;
#    : print_standard; #if not, print normally;