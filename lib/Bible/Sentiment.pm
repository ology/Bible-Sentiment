package Bible::Sentiment;

# ABSTRACT: Show Bible Sentiment Charts

use Dancer2;

use lib '/Users/gene/sandbox/Lingua-EN-Opinion/lib';
use Lingua::EN::Opinion;

use File::Find::Rule;
use List::Util qw( min max sum0 );
use Statistics::Lite qw( mean );

our $VERSION = '0.01';

=head1 NAME

Bible::Sentiment - Show Bible Sentiment Charts

=head1 DESCRIPTION

A C<Bible::Sentiment> shows charts of Bible sentiment.

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

    my $opinion = Lingua::EN::Opinion->new( file => $file[0] );
    $opinion->analyze();

    my @locations;
    my $score_text = '';
    if ( $chunk == 1 ) {
        my $i = 0;
        for my $sentence ( @{ $opinion->sentences } ) {
            push @locations, $i
                if $term && $sentence =~ /$term/;
            $i++;
        }

        my %score;
        @score{ @{ $opinion->sentences } } = @{ $opinion->scores };

        my $min = min( @{ $opinion->scores } );
        my $max = max( @{ $opinion->scores } );

        $score_text .= "Most positive sentences:\n\n";
            for my $positive ( map { [ $score{$_} => $_ ] } @{ $opinion->sentences } ) {
                next unless $positive->[0] == $max;
                $score_text .= "$positive->[1]\n";
            }
        $score_text .= "\n";
        $score_text .= "Most negative sentences:\n\n";
            for my $negative ( map { [ $score{$_} => $_ ] } @{ $opinion->sentences } ) {
                next unless $negative->[0] == $min;
                $score_text .= "$negative->[1]\n";
            }
        $score_text .= "\nAverage sentence score: " . mean( @{ $opinion->scores } ) . "\n";
        $score_text .= "\nTotal sentence score: " . sum0( @{ $opinion->scores } ) . "\n";
    }

    my $score = $opinion->averaged_score($chunk);

    template 'index' => {
        title     => 'Bible::Sentiment',
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

true;

__END__

=head1 SEE ALSO

L<Dancer2>

L<Lingua::EN::Opinion>

=cut
