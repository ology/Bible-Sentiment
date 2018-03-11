#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Bible::Sentiment;

Bible::Sentiment->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Bible::Sentiment;
use Plack::Builder;

builder {
    enable 'Deflater';
    Bible::Sentiment->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use Bible::Sentiment;
use Bible::Sentiment_admin;

use Plack::Builder;

builder {
    mount '/'      => Bible::Sentiment->to_app;
    mount '/admin'      => Bible::Sentiment_admin->to_app;
}

=end comment

=cut

