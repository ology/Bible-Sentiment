use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'Bible::Sentiment',
    AUTHOR              => q{Gene Boggs <gene@ology.net>},
    VERSION_FROM        => 'lib/Bible/Sentiment.pm',
    ABSTRACT            => 'Show Bible Sentiment Charts',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer2'     => 0.205002,
        'Lingua::EN::Opinion' => 0,
        'File::Find::Rule' => 0,
        'List::Util' => 0,
        'Statistics::Lite' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Bible-Sentiment-*' },
);
