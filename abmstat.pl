#!/usr/bin/perl -w

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}
use C4::Context;
use Template;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

# Configure the Template Toolkit
my $config = {
    INCLUDE_PATH => 'tt2',  # or list ref
    INTERPOLATE  => 1,               # expand "$var" in plain text
    POST_CHOMP   => 0,               # cleanup whitespace 
};
# create Template object
my $tt2 = Template->new($config) || die Template->error(), "\n";

# Get command line options
my ($homebranch, $verbose) = get_options();

if ($verbose) {
	print "This is abmstat.pl, running in verbose mode.\n";
	print "Getting data for branch sksk.\n";
}

# Get database connection
my $dbh   = C4::Context->dbh;

# Config
my @itemtypes = ({
	name       => 'Bøker og periodika (antall bind)',
	itypes     => ["BOK", "LRM"],
	holdings   => 0,
	holdings_n => '007',
	added      => 0,
	added_n    => '008',
	deleted    => 0, 
	deleted_n  => '009'
}, 	{
	name       => 'AV-dokumenter',
	itypes     => ["DVD", "LBOK", "VID"],
	holdings   => 0,
	holdings_n => '023',
	added      => 0,
	added_n    => '024',
	deleted    => 0, 
	deleted_n  => '025'
},	{
	name       => 'Annet bibliotekmateriale',
	itypes     => ["X"],
	holdings   => 0,
	holdings_n => '023',
	added      => 0,
	added_n    => '024',
	deleted    => 0, 
	deleted_n  => '025'
}, 	{
	name       => 'Andre digitale dokumenter',
	itypes     => ["DIG"],
	holdings   => 0,
	holdings_n => '047',
	added      => 0,
	added_n    => '048',
	deleted    => 0, 
	deleted_n  => '049'
});

my $count = scalar(@itemtypes);

for (my $i=0; $i < $count; $i++) {

	# Holdings
	my $hold_query = "SELECT count(biblionumber)
					FROM items 
					WHERE YEAR(dateaccessioned) < 2010
					AND homebranch = '" . $homebranch . "'
					AND " . orify('itype', @{$itemtypes[$i]{'itypes'}});
	print "$hold_query\n";
	my $hold_sth = $dbh->prepare($hold_query);
	$hold_sth->execute();
	my $hold_count = $hold_sth->fetchrow;
	$itemtypes[$i]{'holdings'} = $hold_count;
	
	# Additions
	my $acq_query = "SELECT count(biblionumber)
					FROM items 
					WHERE YEAR(dateaccessioned) = 2009
					AND homebranch = '" . $homebranch . "'
					AND " . orify('itype', @{$itemtypes[$i]{'itypes'}});
	my $acq_sth = $dbh->prepare($acq_query);
	$acq_sth->execute();
	my $acq_count = $acq_sth->fetchrow;
	if (!$acq_count) { $acq_count = 0; }
	$itemtypes[$i]{'added'} = $acq_count;
	
	# Deletions
	my $del_query = "SELECT count(itemnumber) 
	                 FROM deleteditems
	                 WHERE YEAR(timestamp) = 2009 
	                 AND homebranch = '" . $homebranch . "'
					 AND " . orify('itype', @{$itemtypes[$i]{'itypes'}});
	my $del_sth = $dbh->prepare($del_query);
	$del_sth->execute();
	my $del_count = $del_sth->fetchrow;
	if (!$del_count) { $del_count = 0; }
	$itemtypes[$i]{'deleted'} = $del_count;
	
	if ($verbose) {
		print $itemtypes[$i]{'name'}, ": $hold_count\t+$acq_count\t-$del_count\n";
	}

}

# Periodicals - TODO! 
my @peri = (
	{
	name => 'Unike titler', 
	holdings => 0, 
	holdings_n => '062', 
	added => 0, 
	added_n => '063', 
	deleted => 0, 
	deleted_n => '064'
	}, {
	name => 'Trykte', 
	holdings => 0, 
	holdings_n => '065', 
	added => 0, 
	added_n => '066', 
	deleted => 0, 
	deleted_n => '067'
	}, {
	name => 'Elektroniske', 
	holdings => 0, 
	holdings_n => '068', 
	added => 0, 
	added_n => '069', 
	deleted => 0, 
	deleted_n => '070'
	}
);

my $peri_query = "select count(*) from subscription where branchcode = '$homebranch'";
my $peri_sth = $dbh->prepare($peri_query);
$peri_sth->execute();
my $peri_count = $peri_sth->fetchrow;
if (!$peri_count) { $peri_count = 0; }
$peri[0]{'holdings'} = $peri_count;

# Circulation
my %circ = ({
	name         => 'Originaldokumenter',
	type         => "issue",
	internal     => 0,
	internal_n   => '081',
	internal_sql => "'ELE' or 'KAD' or 'VER' or 'ANS' or 'BIB'", 
	external     => 0,
	external_n   => '082', 
	external_sql => "'EKS' or 'BIBLIOTEK'"
}, {
	name       => 'herav fornyelser',
	type       => "renew",
	internal   => 0,
	internal_n => '150',
	internal_sql => "'ELE' or 'KAD' or 'VER' or 'ANS' or 'BIB'",
	external   => 0,
	external_n => '151', 
	external_sql => "'EKS' or 'BIBLIOTEK'"
});

# select count(*) from statistics where branch = 'sksk' and YEAR(datetime) = 2009 and DATE(datetime) > '2009-10-22';
# select count(*), b.categorycode from statistics as s, borrowers as b where s.borrowernumber = b.borrowernumber and s.branch = 'sksk' and type = 'issue' and YEAR(s.datetime) = 2009 and DATE(s.datetime) > '2009-10-22' group by b.categorycode;

# Output
my $template = 'abmstat.tt2';
my $vars = {
	'holdings'  => \@itemtypes,
	'periodicals' => \@peri 
};
my $htmlfile = "/home/sksk/public_html/abmstats.html";
$tt2->process($template, $vars, $htmlfile) || die $tt2->error();
print "Go have a look at $htmlfile \n";

# Takes the name of a column and an array of values and creates a list of ORed values: 
# In: orify('i.itype', ['DVD', 'LBOK', 'VID']);
# Out: "(i.itype = 'DVD' OR i.itype = 'LBOK' OR i.itype = 'VID')"
sub orify {
	my $column = shift;
	my @values = @_;
	my $count = 0;
	my $out = '(';
	for my $value (@values) {
		if ($count > 0) {
			$out .= " OR ";
		}
		$out .= "$column = '" . $value . "'";
		$count++; 
	}
	$out .= ')';
	return $out;
}

# Get commandline options
sub get_options {
  my $homebranch = '';
  my $verbose = '';
  my $help = '';

  GetOptions("b|homebranch=s" => \$homebranch, 
             "v|verbose!" => \$verbose,
             'h|?|help'   => \$help
             );
  
  pod2usage(-exitval => 0) if $help;
  pod2usage( -msg => "\nMissing Argument: -b, --homebranch required\n", -exitval => 1) if !$homebranch;

  return ($homebranch, $verbose);
}       

__END__

=head1 NAME
    
abmstat.pl - Collect statistics for the Norwegian library authorities.
        
=head1 SYNOPSIS
            
abmstat.pl > stats.html
               
=head1 OPTIONS
              
=over 8

=item B<-b, --homebranch>

Restrict results to one branch. 
                                                   
=item B<-v, --verbose>

Run in verbose mode, with extra output. 

=item B<-h, -?, --help>
                                               
Prints this help message and exits.

=back
                                                               
=cut