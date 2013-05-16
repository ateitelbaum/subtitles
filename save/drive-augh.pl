## posted:
## http://stackoverflow.com/questions/16239390/re-inserting-file-to-google-drive-through-api

use google ;
use MimeTypes ;
use JSON ;
use MIME::Lite ;
do '/tmp/g.pl' ;

$token = Google::OAuth->token('tqiscoco@gmail.com') ;
$o = Google::Drive->new( $token ) ;
%items = map { $_->{title} => $_ } @{ $o->{items} } ;

$parents = [ { id => $items{'about me'}->{id} } ] ;
$doc = { title => 'hi.txt' } ;
$doc->{parents} = $parents ;
$doc->{mimeType} = $MimeTypes::types{jpg} ;

$content = JSON::to_json( $doc ) ;

$m = MIME::Lite->new( Type => 'multipart/mixed' ) ;
$m->attach( Type => 'application/json', Data => $content ) ;
$m->attach( Type => $doc->{mimeType},
		Encoding => 'base64', 
		Path => '/tmp/'.$doc->{title} ) ;

## stupid feature missing from MIME::Lite
%headers = map { split /: /, $_, 2 } 
		grep $_, split /\n/, $m->header_as_string ;
$header = <<'eof' ;
multipart/mixed; boundary="_----------=_1366988413143310"
eof

chomp( $header ) ;

sub dothis {
	$hh = Google::OAuth::Headers->new( $token ) ;
	$hh->add( 'Accept-Encoding' => 'base64' ) ;

	$out = $hh->content( POST => Google::Drive->upload, 
			$header, $body[2] ) ;
	do 'perlterm.pl' if ref $out ;
	print $out, "\n" ;
	}

## Remarkably, this works!
$body[0] =<<'eof' ;
--_----------=_1366988413143310
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Content-Type: application/json

{"mimeType":"image/jpeg","title":"hi.txt","parents":[{"id":"0BxnfVWt9egI_VDJnbFBpZDExTmM"}]}
--_----------=_1366988413143310
Content-Disposition: inline; filename="hi.txt"
Content-Type: image/jpeg; name="hi.txt"

c2V0UGVuZGluZ1NhdmUKbG9hZFNlZ21lbnRzCnNldFNlcXVlbmNlCmFkZFNl
Z21lbnQKc2V0c3BhbmZvcm1hdApzZXRzcGFuZm9ybWF0CmhpZGVzcGFuZm9y
bWF0CnNldHNwYW5mb3JtYXQKc2V0c3BhbmZvcm1hdApoaWRlc3BhbmZvcm1h
dAo=
--_----------=_1366988413143310--
eof

## This fails: Multipart content has too many non-media parts
$body[1] =<<'eof' ;
--_----------=_1366988413143310
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Content-Type: application/json

{"mimeType":"text/plain","title":"hi.txt","parents":[{"id":"0BxnfVWt9egI_VDJnbFBpZDExTmM"}]}
--_----------=_1366988413143310
Content-Disposition: inline; filename="hi.txt"
Content-Type: text/plain; name="hi.txt"

c2V0UGVuZGluZ1NhdmUKbG9hZFNlZ21lbnRzCnNldFNlcXVlbmNlCmFkZFNl
Z21lbnQKc2V0c3BhbmZvcm1hdApzZXRzcGFuZm9ybWF0CmhpZGVzcGFuZm9y
bWF0CnNldHNwYW5mb3JtYXQKc2V0c3BhbmZvcm1hdApoaWRlc3BhbmZvcm1h
dAo=
--_----------=_1366988413143310--
eof

$body[2] =<<'eof' ;
This is a multi-part message in MIME format.

--_----------=_1366988413143310
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Content-Type: application/json

{"mimeType":"image/jpeg","title":"hi.txt","parents":[{"id":"0BxnfVWt9egI_VDJnbFBpZDExTmM"}]}
--_----------=_1366988413143310
Content-Disposition: inline; filename="hi.txt"
Content-Transfer-Encoding: base64
Content-Type: image/jpeg; name="hi.txt"

c2V0UGVuZGluZ1NhdmUKbG9hZFNlZ21lbnRzCnNldFNlcXVlbmNlCmFkZFNl
Z21lbnQKc2V0c3BhbmZvcm1hdApzZXRzcGFuZm9ybWF0CmhpZGVzcGFuZm9y
bWF0CnNldHNwYW5mb3JtYXQKc2V0c3BhbmZvcm1hdApoaWRlc3BhbmZvcm1h
dAo=

--_----------=_1366988413143310--
eof

## More or less the data produced by MIME::Lite
$body[3] =<<'eof' ;
This is a multi-part message in MIME format.

--_----------=_1366988413143310
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Content-Type: application/json

{"mimeType":"image/jpeg","title":"hi.txt","parents":[{"id":"0BxnfVWt9egI_VDJnbFBpZDExTmM"}]}
--_----------=_1366988413143310
Content-Disposition: inline; filename="hi.txt"
Content-Transfer-Encoding: base64
Content-Type: image/jpeg; name="hi.txt"

c2V0UGVuZGluZ1NhdmUKbG9hZFNlZ21lbnRzCnNldFNlcXVlbmNlCmFkZFNl
Z21lbnQKc2V0c3BhbmZvcm1hdApzZXRzcGFuZm9ybWF0CmhpZGVzcGFuZm9y
bWF0CnNldHNwYW5mb3JtYXQKc2V0c3BhbmZvcm1hdApoaWRlc3BhbmZvcm1h
dAo=

--_----------=_1366988413143310--
eof

&dothis ;

## The original is below:
__END__
use google ;
use MimeTypes ;
use JSON ;
use MIME::Lite ;

$token = Google::OAuth->token('tqiscoco@gmail.com') ;
$o = Google::Drive->new( $token ) ;
%items = map { $_->{title} => $_ } @{ $o->{items} } ;

$parents = [ { id => $items{'about me'}->{id} } ] ;
$doc = { title => 'Friday8-12 042.JPG' } ;
$doc->{parents} = $parents ;
$doc->{mimeType} = $MimeTypes::types{jpg} ;

$content = JSON::to_json( $doc ) ;

$m = MIME::Lite->new( Type => 'multipart/mixed' ) ;
$m->attach( Type => 'application/json', Data => $content ) ;
$m->attach( Type => $doc->{mimeType},
		Encoding => 'base64', 
		Path => 'about me/'.$doc->{title} ) ;

## stupid feature missing from MIME::Lite
%headers = map { split /: /, $_, 2 } 
		grep $_, split /\n/, $m->header_as_string ;

$out = $token->content( POST => Google::Drive->upload, 
		$headers{'Content-Type'}, 
		$m->body_as_string ) ;
