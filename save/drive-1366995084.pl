use google ;
use MimeTypes ;
use JSON ;
use MIME::Entity ;
use File::Basename ;

warn unless @ARGV ;

$token = Google::OAuth->token('tqiscoco@gmail.com') ;
$o = Google::Drive->new( $token ) ;
%items = map { $_->{title} => $_ } @{ $o->{items} } ;

@fn = ( $ARGV[0] ) ;
push @fn, fileparse( $fn[0] ) ;
$path = $fn[2] ;
$path =~ s|/$|| ;

$parents = [ { id => $items{ $path }->{id} } ] ;

$doc = { title => $fn[1] } ;
$doc->{parents} = $parents ;
$doc->{mimeType} = $MimeTypes::types{jpg} ;

$content = JSON::to_json( $doc ) ;

$m = MIME::Entity->build( Type => 'multipart/mixed' ) ;
$m->attach( Type => 'application/json', 
		Encoding => '7bit',
		Data => $content ) ;
$m->attach( Type => $doc->{mimeType},
		Encoding => 'binary', 
		Path => 'about me/'.$doc->{title} ) ;

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

do 'perlterm.pl' if ref $out ;
print $out, "\n" ;

__END__
join "\n", %$m ;
join "\n", %{ $m->{mail_inet_head} } ;
join "\n", %{ $m->{mail_inet_head}->{mail_hdr_hash} } ;
join "\n", %{ $m->{mail_inet_head}->{mail_hdr_hash}->{Content-Type} } ;
join "\n", @{ $m->{mail_inet_head}->{mail_hdr_hash}->{'Content-Type'} } ;
${ $m->{mail_inet_head}->{mail_hdr_hash}->{'Content-Type'}->[0] } ;
