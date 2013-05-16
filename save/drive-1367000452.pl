use google ;
use MimeTypes ;
use JSON ;
use MIME::Entity ;
use File::Basename ;
use Getopt::Std ;

getopts( 'op:t' ) ;

$token = Google::OAuth->token('tqiscoco@gmail.com') ;
$o = Google::Drive->new( $token ) ;
%items = map { $_->{title} => $_ } @{ $o->{items} } ;

if ( $opt_t ) {
	do 'perlterm.pl' ;
	exit ;
	}

die unless @ARGV ;

if ( -d $ARGV[0] ) {
	my $k = shift @ARGV if @ARGV > 1 ;
	my $parent = $opt_p || $items{ $k || 'Website' }->{id} ;
	my $parents = [ { id => $parent } ] ;
	my $doc = { title => $ARGV[0] } ;
	$doc->{parents} = $parents ;
	$doc->{mimeType} = 'application/vnd.google-apps.folder' ;
	my $content = JSON::to_json( $doc ) ;

	$out = $token->content( POST => Google::Drive->url, 
			'application/json', 
			$content ) ;
	do 'perlterm.pl' ;
	exit ;
	}

@fn = ( $ARGV[0] ) ;
push @fn, fileparse( $fn[0] ) ;
push @fn, split /\./, $fn[1] ;
$path = $fn[2] ;
$path =~ s|/$|| ;

$parent = $opt_p || $items{ $path }->{id} ;
$parents = [ { id => $parent } ] ;

$doc = { title => $fn[1] } ;
$doc->{parents} = $parents ;
$doc->{mimeType} = $MimeTypes::types{ $fn[-1] } 
		or die "Unknown Mime Type" ;

$content = JSON::to_json( $doc ) ;

$m = MIME::Entity->build( Type => 'multipart/mixed' ) ;
$m->attach( Type => 'application/json', 
		Encoding => '7bit',
		Data => $content ) ;
$m->attach( Type => $doc->{mimeType},
		Encoding => 'binary', 
		Path => $fn[0] ) ;

## MIME::Entity is even more limited that MIME::Lite

@headers = split /: /, 
	${ $m->{mail_inet_head}->{mail_hdr_hash}->{'Content-Type'}->[0] },
	2 ;
$header = $headers[1] ;
chomp( $header ) ;

$content = $m->stringify_body ;
$content =~ s/^[^-]*-//s ;
$content =~ s/^[^-]*-/-/s ;
$content =~ s/\bContent-Transfer-Encoding: [^\n]*\n//g ;

$out = $token->content( POST => Google::Drive->upload, 
		$header, $content ) ;

do 'perlterm.pl' if $opt_o ;
print $out, "\n" ;

__END__
join "\n", %$m ;
join "\n", %{ $m->{mail_inet_head} } ;
join "\n", %{ $m->{mail_inet_head}->{mail_hdr_hash} } ;
join "\n", %{ $m->{mail_inet_head}->{mail_hdr_hash}->{Content-Type} } ;
join "\n", @{ $m->{mail_inet_head}->{mail_hdr_hash}->{'Content-Type'} } ;
${ $m->{mail_inet_head}->{mail_hdr_hash}->{'Content-Type'}->[0] } ;
