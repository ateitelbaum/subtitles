package Google::OAuth;
use base NoSQL::PL2SQL ;
use LWP::UserAgent ;
use CGI::Simple ;
use JSON::Parse ;

## local installation
use NoSQL::PL2SQL::DBI::MySQL ;
use mysql ;

use 5.008009;
use strict;
use warnings;

require Exporter;

push @Google::OAuth::ISA, qw( Exporter Google::OAuth::Request ) ;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Google::OAuth ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw() ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } ) ;

our @EXPORT = qw( json_to_perl );

our $VERSION = '0.01';


# Preloaded methods go here.

my %google ;
my %client ;

$client{redirect_uri} = 'http://www.tqis.com/pen/misc/googleauth.htm' ;
$client{client_id} = '587970581362.apps.googleusercontent.com' ;
$client{client_secret} = 'xAtNohxjOd0IrsZy0VPStR-a' ;

$client{dsn} = NoSQL::PL2SQL::DBI::MySQL->new('giggle')->mysql ;

$google{oauth} = 'https://accounts.google.com/o/oauth2/auth';
$google{token} = 'https://accounts.google.com/o/oauth2/token';

my %scopes = (
	'm8.feeds' 
			=> 'https://www.google.com/m8/feeds',
	'calendar' 
			=> 'https://www.googleapis.com/auth/calendar',
	'calendar.readonly' 
			=> 'https://www.googleapis.com/auth/calendar.readonly',
	'drive.readonly' 
			=> 'https://www.googleapis.com/auth/drive.readonly',
        ) ;

## not a method
sub dsn {
	return $client{dsn} ;
	}

## not a method
sub json_to_perl {
	my $json = shift ;
	$json =~ s/ (true|false)/ "$1"/sg ;
	return JSON::Parse::json_to_perl( $json ) ;
	}

my $duplicate = sub {
	my ( $emailkey, $errorcode, $perldata, $zero, $obj, $errorstring ) 
			= @_ ;
	my $package = ref $obj ;
	my $u = $package->SQLObject( $emailkey ) ;
	my %keys = map { $_ => 1 } keys %$u, keys %$obj ;

	map { exists $obj->{$_}? 
			( $u->{$_} = $obj->{$_} ):
			( delete $u->{$_} ) } keys %keys ;
	return bless $u, $package ;
	} ;

sub SQLClone {
	my $arg = shift ;
	my ( $self, $package ) = ref $arg? ( $arg, ref $arg ): ( undef, $arg ) ;
	$self ||= $package->SQLObject( @_ ) ;

	return bless NoSQL::PL2SQL::SQLClone( $self ), $package ;
	}

sub SQLObject {
	my $package = shift ;
	my $email = shift ;
	NoSQL::PL2SQL::SQLError( $email, 
			DuplicateObject => $duplicate ) ;
	my @args = ( $email, $client{dsn}, 0 ) ;

	push @args, bless $_[0], $package if @_ ;
	my $out = NoSQL::PL2SQL::SQLObject( @args ) ;
	return $out? bless( $out, $package ): undef ;
	}

sub scope {
	shift @_ if $_[0] eq __PACKAGE__ ;
	my $self = ref $_[0] eq __PACKAGE__? shift @_: undef ;

	my $scope = join ' ', map { $scopes{$_} } @_ ;
	return $scope unless $self ;

	$self->{scope} = $scope ;
	return $self ;
	}

sub queryargs {
	shift @_ if $_[0] eq __PACKAGE__ || ref $_[0] eq __PACKAGE__ ;
	my %out = map { ref $_? %$_: ( $_ => $client{$_} ) } @_ ; 
	return \%out ;
	}

sub new {
	my $package = shift ;
	my $self = {} ;
	$self->{args} = $package->queryargs( @_ ) ;
	return bless $self, $package ;
	}

sub auth_link {
	my $self = shift ;
	my $args = $self->{args} ;
	$args = queryargs( 'client_id', 'redirect_uri',
			{ response_type => 'code' },
			{ approval_prompt => 'force' },
			{ access_type => 'offline' }
			) unless %$args ;
	$args->{scope} = $self->{scope} if $self->{scope} ;
	
	my $kurl = shift ;
	$kurl ||= 'oauth' ;
	return join '?', $google{$kurl}, 
			CGI::Simple->new( $args )->query_string ;
	}

## arguments for authcode
## get_token( 'redirect_uri', { code => $code }, { grant_type => 'authorization_code' } )

## arguments for renewal
## get_token( { refresh_token => $refresh }, { grant_type => 'refresh_token' } )

sub get_token {
	my $arg = shift ;
	my ( $package, $self ) = ref $arg?
			( ref $arg, $arg ):
			( $arg, $arg->new( 
			  'client_id', 'client_secret', @_ ) ) ;

	my $request = Google::OAuth::Request->request( 
			POST => $google{token},
			CGI::Simple->new( $self->{args} )->query_string
			) ;

	my $content = LWP::UserAgent->new->request( $request )->content ;
	return $content unless $content =~ /^{/s ;
	return bless json_to_perl( $content ), $package ;
	}

sub emailkey {
	my $self = shift ;
	my $url = 'https://www.googleapis.com'
				.'/calendar/v3/users/me/calendarList' ;
	my $r = $self->request( GET => $url ) ;
	my $calinfo = Google::OAuth::json_to_perl( 
			LWP::UserAgent->new->request( $r )->content
			) ;
	my @owner = grep $_->{accessRole} eq 'owner', @{ $calinfo->{items} } ;
	return $self->{emailkey} = $owner[0]->{summary} ;
	}

sub headers {
	my $self = shift ;
	my $method = shift ;

	return Google::OAuth::Request::headers( $method ),
			Authorization =>
			  join ' ', @$self{ qw( token_type access_token ) } ;
	}

sub grant_code {
	my $package = shift @_ ;
	my $code = shift ;
	my $token = $package->get_token( 'redirect_uri', { code => $code }, 
			{ grant_type => 'authorization_code' } ) ;

	my $key = $token->emailkey if $token->{access_token} ;
	return $key? $package->SQLObject( $key => $token ): $token ;
	}

sub token {
	my $self = shift ;
	my $package = ref $self ;

	my $rr = 'refresh_token' ;
	my $token = $package->get_token( 
			{ $rr => $self->{$rr} }, 
			{ grant_type => $rr } 
			) ;

	if ( ref $token && $token->{access_token} ) {
		map { $self->{$_} = $token->{$_} } keys %$token ;
		}
	else {
		my $error = ref $token? join( "\n", %$token ): $token ;
		warn join "\n", 'Access renewal failed:', $error, '' ;
		}

	## Object may be a clone
	unless ( defined $self->SQLObjectID ) {
		my $package = ref $self ;
		my $temp = $package->SQLObject( $self->{emailkey} ) ;
		map { $temp->{$_} = $self->{$_} } keys %$self ;
		$self = $temp->SQLClone ;
		}

	return $self ;
	}


package Google::OAuth::Request ;

my %content_type = () ;
$content_type{POST} = 'application/x-www-form-urlencoded' ;
$content_type{GET} = 'application/http' ;

sub request {
	my $self = shift ;
	my $method = shift ;
	my $uri = shift ;

	my @hh = $self->headers( $method ) ;
	push @hh, 'Content-Length' => length $_[0] if $method eq 'POST' ;
	my @args = ( \@hh, @_ ) ;
	return new HTTP::Request( $method, $uri, @args ) ;
	}

sub headers {
	shift @_ if $_[0] eq __PACKAGE__ ;
	shift @_ if ref $_[0] eq __PACKAGE__ ;

	my $method = shift ;

	return (
		'Content-Type' => $content_type{$method},
		) ;
	}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Google::OAuth - Maintains a database for Google Access Tokens

=head1 SYNOPSIS

  use Google::OAuth;

=head1 DESCRIPTION

Stub documentation for Google::OAuth, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

root, E<lt>root@tqis.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by root

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut

