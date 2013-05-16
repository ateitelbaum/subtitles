package Google::OAuth::Config ;

our %test ;
my %client ;

$client{client_id} = '' ;
$client{client_secret} = '' ;
$client{redirect_uri} = '' ;

$test{grantcode} = '' ;

BEGIN {
	use 5.008009;
	use strict;
	use warnings;
	
	require Exporter;
	
	our @ISA = qw( Exporter ) ;
	
	our %EXPORT_TAGS = ( 'all' => [ qw() ] );
	our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } ) ;
	our @EXPORT = qw() ;
	our $VERSION = '0.01';
	}

sub setclient {
	return %client ;
	}

1;
