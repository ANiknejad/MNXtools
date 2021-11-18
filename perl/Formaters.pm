package Formaters;
#Filename Formaters.pm

use strict;
use warnings;
use diagnostics;
use FindBin qw( $RealBin );
use lib "$RealBin/../perl";
use Constants;
use Prefix;


our $prefixes = Prefix->new( $RealBin . '/../perl/Prefix.tsv' );

sub convert_to_Sid {
    my ($id) = @_;

    $id =~ s{\s+}{}g;
    $id =~ s{\W}{_}g;

    return $id;
}

sub clean_Note {
    my ($note) = @_;

    $note =~ s{^.*?: *_*\|?(.+?)\|?$}{$1};

    return trim($note);
}

sub trim {
    my ($string) = @_;

    $string =~ s{^\s+}{};
    $string =~ s{\s+$}{};

    return $string;
}


sub protect_char {
    my ($string) = @_;

    $string =~ s{__45__}{-}g;
    $string =~ s{__64__}{\@}g;
    $string =~ s{__43__}{\+}g;
    $string =~ s{__91__}{\[}g;
    $string =~ s{__93__}{\]}g;
    #TODO Add others

    return $string;
}


sub format_Compartment {
    my ($compartment_Sid) = @_;

    $compartment_Sid =~ s{^C_(.+)$}{$1};

    return protect_char($compartment_Sid);
}

sub format_Chemical {
    my ($chemical_Sid, $compartment_Sid, $original_boundary_compartment) = @_;

    my $compartment_in_chem = $compartment_Sid;
    if ( $original_boundary_compartment && $Constants::boundary_comp_id eq $compartment_Sid ){
        $compartment_in_chem = $original_boundary_compartment;
    }

#    $chemical_Sid =~ s{^M_(.+)$}{$1};
    $chemical_Sid =~ s{^_+(.+)$}{$1};
    # Different cases of compartement pasted at the end of chemical id
    if ( $chemical_Sid =~ /^(.+?)__64__${compartment_in_chem}$/ ){
        $chemical_Sid = $1;
    }
    elsif ( $chemical_Sid =~ /^(.+?)_${compartment_in_chem}$/ ){
        $chemical_Sid = $1;
    }
    elsif ( $chemical_Sid =~ /^(.+?)\[${compartment_in_chem}\]$/ ){
        $chemical_Sid = $1;
    }
    elsif ( $chemical_Sid =~ /^(.+?)__91__${compartment_in_chem}__93__$/ ){
        $chemical_Sid = $1;
    }
    elsif ( $chemical_Sid =~ /^(.+?)\@${compartment_in_chem}$/ ){
        $chemical_Sid = $1;
    }
    elsif ( $chemical_Sid =~ /^(.+?)${compartment_in_chem}$/ ){
        $chemical_Sid = $1;
    }
    #Compartment letter is not the same than compartment attribute value
    #TODO improve this
    elsif ( $chemical_Sid =~ /^(.+?)_[a-z]$/ ){
        $chemical_Sid = $1;
    }

    return protect_char($chemical_Sid);
}

sub format_Reaction {
    my ($reaction_Sid) = @_;

    $reaction_Sid =~ s{^R_(.+)$}{$1};
    $reaction_Sid =~ s{^_+(.+)$}{$1};

    return protect_char($reaction_Sid);
}

sub format_GeneProduct {
    my ($geneProduct_Sid) = @_;

    $geneProduct_Sid =~ s{^G_(.+)$}{$1};
    $geneProduct_Sid =~ s{^_+(.+)$}{$1};
    $geneProduct_Sid =~ s{__46__}{.}g;

    return protect_char($geneProduct_Sid);
}

#TODO GO, CL and CCO not in comp(artments)?
#TODO uniprotkb for all peptides?
#FIXME kegg chem can be 4 different things (3 if we exclude kegg environ now)
sub guess_prefix {
    my ($scope, $full_prefix) = @_;
    my ($prefix, $id) = split(/:/, $full_prefix, 2);
    if ( !$id ){
        $id     = $prefix;
        $prefix = 'mnx';
    }
    if ( $prefix eq 'chebi' ){
        $prefix = 'CHEBI';
    }

    my $right_prefix = $Formaters::prefixes->{'fromSBML'}->{$scope}->{$prefix} || $prefix;
    return "$right_prefix:$id";
}

1;

