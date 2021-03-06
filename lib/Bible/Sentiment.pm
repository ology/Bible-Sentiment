package Bible::Sentiment;

# ABSTRACT: Show Bible Sentiment Charts

use Dancer2;

use lib '/Users/gene/sandbox/Lingua-EN-Opinion/lib';
use Lingua::EN::Opinion;

use File::Find::Rule;
use List::Util qw( min max sum0 );
use Statistics::Lite qw( mean );
use Data::Dumper;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Varname   = 'score';

our $VERSION = '0.01';

=head1 NAME

Bible::Sentiment - Show Bible Sentiment Charts

=head1 DESCRIPTION

C<Bible::Sentiment> shows charts of Bible text sentiment analysis.

=head1 ROUTES

=head2 /

Main page.

=cut

any '/' => sub {
    my $book  = body_parameters->get('book')  || query_parameters->get('book')  || '01';
    my $chunk = body_parameters->get('chunk') || query_parameters->get('chunk') || 5;
    my $term  = body_parameters->get('term')  || query_parameters->get('term')  || '';

    my @files = File::Find::Rule->file()->name('*.txt')->in('public/text');
    my @file  = grep { /$book/ } @files;

    my $name;
    my $books;
    for my $file ( @files ) {
        if ( $file =~ /^public\/text\/(\d+)-(.*?)\.txt$/ ) {
            $books->{$2} = $1;
            $name = $2
                if $1 eq $book;
        }
    }

    my $opinion = Lingua::EN::Opinion->new( file => $file[0], stem => 1 );
    $opinion->analyze();

    my @locations;
    my $score_text = '';
    if ( $chunk == 1 ) {
        if ( $term ) {
            my $i = 0;  # Position counter
            my $j = 0;  # Occurrence counter
            for my $sentence ( @{ $opinion->sentences } ) {
                if ( $sentence =~ /$term/ ) {
                    $j++;
                    push @locations, $i;
                    $score_text .= ( $i + 1 ) . ". $sentence\n\n";
                }
                $i++;
            }
            $score_text = "<b>$j occurrences of '$term'</b>:\n\n" . $score_text;
        }
        else {
            my %score;
            @score{ @{ $opinion->sentences } } = @{ $opinion->scores };

            my $min = min( @{ $opinion->scores } );
            my $max = max( @{ $opinion->scores } );

            $score_text .= "<b>Most positive sentences</b>:\n\n";
            for my $positive ( map { [ $score{$_} => $_ ] } @{ $opinion->sentences } ) {
                next unless $positive->[0] == $max;
                $score_text .= "$positive->[1]\n\n";
            }
            $score_text .= "\n<b>Most negative sentences</b>:\n\n";
            for my $negative ( map { [ $score{$_} => $_ ] } @{ $opinion->sentences } ) {
                next unless $negative->[0] == $min;
                $score_text .= "$negative->[1]\n\n";
            }
            $score_text .= "\n<b>Total sentence score</b>: " . sum0( @{ $opinion->scores } ) . "\n";
            $score_text .= "\n<b>Total number of sentences</b>: " . scalar( @{ $opinion->sentences } ) . "\n";
            $score_text .= "\n<b>Average sentence score</b>: " . mean( @{ $opinion->scores } ) . "\n";
        }
    }

    my $score = $opinion->averaged_score($chunk);

    template 'index' => {
        labels    => [ 1 .. @$score ],
        data      => $score,
        label     => $name,
        books     => $books,
        book      => $book,
        chunk     => $chunk,
        prevbook  => sprintf( '%02d', $book - 1 ),
        nextbook  => sprintf( '%02d', $book + 1 ),
        locations => \@locations,
        term      => $term,
        text      => $score_text,
    };
};

=head2 /score

Sentence score page.

=cut

any '/score' => sub {
    my $sentence = body_parameters->get('text') || '';

    my $opinion = Lingua::EN::Opinion->new( stem => 1 );

    template 'score' => {
        text      => $sentence,
        score     => Dumper( $opinion->get_sentence($sentence) ),
        nrc_score => Dumper( $opinion->nrc_get_sentence($sentence) ),
    };
};

true;

__END__

=head1 SEE ALSO

L<Dancer2>

L<Lingua::EN::Opinion>

=head1 AUTHOR
 
Gene Boggs <gene@cpan.org>
 
=head1 COPYRIGHT AND LICENSE
 
This software is copyright (c) 2019 by Gene Boggs.
 
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
