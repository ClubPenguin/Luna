use strict;
use warnings;

package Tools;

use Method::Signatures;
use LWP::Simple;
use XML::Simple;
use File::Fetch;
use Coro;
use File::Basename;

method new {
       my $obj = bless {}, $self;
       return $obj;
}

method asyncGetContent(\@arrUrls) {
       my %arrInfo;
       my @arrCoro = map {
                    my $strUrl = $_;
                    async {
                        my $strBase = basename($strUrl);
                        my @arrParts = split('.', $strBase);
                        my $strName = $arrParts[0];
                        my $arrData = get($strUrl);
                        $arrInfo{$strName} = $arrData;
                    }
       } @arrUrls;
       $_->join for @arrCoro;       
       return \%arrInfo;     
} 

method parseXML($strData) {
       my $strXML;
       eval {
          $strXML = XML::Simple::parse_string($strData);
       };
       return $strXML;
}

method asyncDownload($resDir, \@arrUrls) {
       my @arrCoro = map {
                    my $strUrl = $_;
                    async {
                        File::Fetch->new(uri => $strUrl)->fetch(to => $resDir);
                    }
       } @arrUrls;
       $_->join for @arrCoro;        
}

1;