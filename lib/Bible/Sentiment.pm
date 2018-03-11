package Bible::Sentiment;

# ABSTRACT: Show Bible Sentiment Charts

use Dancer2;

use lib '/Users/gene/sandbox/Lingua-EN-Opinion/lib';
use Lingua::EN::Opinion;

use File::Find::Rule

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
    my $book  = body_parameters->get('book') || query_parameters->get('book') || '01';
    my $chunk = body_parameters->get('chunk') || query_parameters->get('chunk') || 5;

    my @files = File::Find::Rule->file()->name( '*.txt' )->in('public/text');
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

    my $score = $opinion->averaged_score($chunk);

    template 'index' => {
        title  => 'Bible::Sentiment',
        labels => [ 1 .. @$score ],
        data   => $score,
        label  => $name,
        books  => $books,
        book   => $book,
        chunk  => $chunk,
        prevbook   => sprintf( '%02d', $book - 1 ),
        nextbook   => sprintf( '%02d', $book + 1 ),
    };
};

true;

__END__

=head1 SEE ALSO

L<Dancer2>

L<Lingua::EN::Opinion>

=cut
