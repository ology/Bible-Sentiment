requires "Dancer2" => "0.205002";
requires "Lingua::EN::Opinion" => "0",
requires "File::Find::Rule" => "0",
requires "List::Util" => "0",
requires "Statistics::Lite" => "0",

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
