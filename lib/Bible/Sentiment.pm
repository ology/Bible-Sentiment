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

get '/:index?' => sub {
    my @files = File::Find::Rule->file()->name( '*.txt' )->in('public/text');

    my $index = route_parameters->get('index');

    my ( $n, $factor ) = split /_/, $index;
    $n ||= '01';    # Genesis
    $factor ||= 5;  # Chunks of 5

    my @file = grep { /$n/ } @files;

    ( my $name = $file[0] ) =~ s/^public\/text\/$n-(.*?)\.txt$/$1/;

    my $opinion = Lingua::EN::Opinion->new( file => $file[0] );
    $opinion->analyze();

    my $score = $opinion->averaged_score($factor);

    template 'index' => {
        title  => 'Bible::Sentiment',
        labels => [ 1 .. @$score ],
        data   => $score,
        label  => $name,
    };
};

true;

__END__

=head1 SEE ALSO

L<Dancer2>

L<Lingua::EN::Opinion>

=cut
