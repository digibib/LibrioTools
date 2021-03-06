# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this file; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

sub client_transform {

  # Define mapping from item types in source to codes for Koha item types
  # To be used in 942c and 952y
  # We will lc before comparing, so use lowercase in the keys
  my %item_types = (
    'musiktryck'             => 'MT', 
    'ljudupptagning'         => 'LJ', 
    'kartografiskt material' => 'MP', 
    'ljudbok (cd)'           => 'LB'
  );

  my $record = shift;

  ### 1. BUILD KOHA-SPECIFIC FIELDS

  # 1a BUILD FIELD 942

  my $field942 = MARC::Field->new(942, '', '', 'a' => 'munkagard');

  # a	Institution code [OBSOLETE]

  # c	Koha [default] item type
  # TODO
  if (my $field245h = lc($record->subfield('245', 'h'))) {
    StripLTSpace($field245h);
    if ($item_types{$field245h}) {
      $field942->add_subfields('c' => $item_types{$field245h});  
    } else {
      $field942->add_subfields('c' => 'BK');	
    }
  } else {
    $field942->add_subfields('y' => 'BK');	
  }

  # e	Edition
  # h	Classification part
  # i	Item part

  # k	Call number prefix
  # m	Call number suffix
  # TODO
  # if ($record->field('096') && $record->field('096')->subfield('a')) {
  #   my $field096a = $record->field('096')->subfield('a');
  #   if ($field096a =~ m/ /) {
  #     my ($pre, $suf) = split / /, $field096a;
  #     $field942->add_subfields('k' => $pre);
  #     $field942->add_subfields('m' => $suf); 
  #   }
  # }

  # n	Suppress in OPAC
  # SUPPRESS  0  	Vis i OPAC
  # SUPPRESS 	1 	Ikke vis i OPAC
  # All records have 099$7 = 1, meaning they should be displayed inn the OPAC
  $field942->add_subfields('n' => 0);

  # s	Serial record flag
  # TODO? 
  # if (lc($record->subfield('245', 'h')) eq 'tidsskrift') {
  #   $field942->add_subfields('s' => '1');	
  # }

  # 0	Koha issues (borrowed), all copies

  # 2	Source of classification or shelving scheme
  # Values are in class_sources.cn_source
  # See also 952$2
  # If 096a starts with three digits we count this as dcc-based scheme
  # TODO
  # if ($record->field('096') && $record->field('096')->subfield('a')) {
  #   my $field096a = $record->field('096')->subfield('a');
  #   if ($field096a =~ m/^[0-9]{3,}.*/) {
  #     $field942->add_subfields('2' => 'ddc');
  #   } else {
  #     $field942->add_subfields('2' => 'z');
  #   }
  # }

  # 6	Koha normalized classification for sorting

  # Add this field to the record
  $record->append_fields($field942);
	
  # 1b BUILD FIELD 952, mostly based on data from 099

  my @field099s = $record->field('099');
  foreach my $field099 (@field099s) {

    # Comments below are from 
    # http://wiki.koha.org/doku.php?id=en:documentation:marc21holdings_holdings_data_information_for_vendors&s[]=952

    # Create field 952, with a = "Permanent location"
    # Authorized value: branches
    # owning library	 
    # Code must be defined in System Administration > Libraries, Branches and Groups
    my $field952 = MARC::Field->new(952, '', '', 'a' => 'munkagard');

    # Get more info for 952, and add subfields

    # b = Current location
    # Authorized value: branches
    # branchcode	 
    # holding library (usu. the same as 952$a )
    $field952->add_subfields('b' => 'munkagard');
	  
    # c = Shelving location
    # TODO
    # Coded value, matching Authorized Value category ('LOC' in default installation)
	# Add a simple, standard value for all records
    $field952->add_subfields('c' => 'BIB');

    # d = Date acquired
    # Format of date: yyyy-mm-dd
    # http://wiki.koha.org/doku.php?id=en:development:dateformats&s[]=952 
    if (my $field099d = $field099->subfield('d')) {
      $field952->add_subfields('d' => $field099d);
    }

    # e = Source of acquisition
    # coded value or vendor string
    # f = Coded location qualifier

    # g = Cost, normal purchase price	
    # decimal number, no currency symbol 
    # TODO? 099g is currency, but 099c price is not used
    # if (my $field020c = $record->subfield('020','c')) {
    #   $field952->add_subfields('g' => $field020c);
    # }

    # h = Serial Enumeration / chronology	
    # See: t

    # j = Shelving control number	
    # STACK

    # l = Total Checkouts	

    # m = Total Renewals	

    # n = Total Holds	

    # o = Full call number 
    # This is stored in either 852c or 852h
    if ($record->field('852')) {
      if ($record->field('852')->subfield('c')) {
        $field952->add_subfields('o' => $record->field('852')->subfield('c'));
      } elsif ($record->field('852')->subfield('h')) {
      	$field952->add_subfields('o' => $record->field('852')->subfield('h'));
      }
    }

    # p = Barcode
    # max 20 characters 
    if (my $field099k = $field099->subfield('k')) {
      $field952->add_subfields('p' => $field099k);
    }

    # q = Checked out

    # r = Date last seen 

    # s = Date last checked out	

    # t = Copy number	
    # 099b contains e.g. "Ex. 1"
    # 099i contains e.g. "1"
    if (my $field099b = $field099->subfield('b')) {
      $field952->add_subfields('t' => $field099b);
    }

    # u = Uniform Resource Identifier	

    # v = Cost, replacement price
    # decimal number, no currency symbol
    # TODO? see g

    # w = Price effective from
    # YYYY-MM-DD 

    # x = Non-public note

    # y = Koha item type
    # coded value, required field for circulation 	 
    # Coded value, must be defined in System Administration > Item types and Circulation Codes
    # TODO is this information anywhere? 245h is only present in 10 records
    if (my $field245h = lc($record->subfield('245', 'h'))) {
      StripLTSpace($field245h);
      if ($item_types{$field245h}) {
    	$field952->add_subfields('y' => $item_types{$field245h});
      } else {
    	$field952->add_subfields('y' => 'BK');	
      }
    } else {
      $field952->add_subfields('y' => 'BK');	
    }

    # z = Public note

    # 0 = Withdrawn status
    # WITHDRAWN

    # 1 = Lost status
    # LOST  	0 
    # LOST 	1 	Lost 
    # LOST 	2 	Long Overdue (Lost) 
    # LOST 	3 	Lost and Paid For
    # LOST 	4 	Missing
    # 099q = Tapt
    # 099q = Savnet
    # 099q = Hevdet innlevert
    # if (my $field099q = $field099->subfield('q')) {
    #   if ($field099q eq 'Tapt') {
    # 	$field952->add_subfields('1' => 1);
    #   } elsif ($field099q eq 'Savnet') {
    # 	$field952->add_subfields('1' => 4);
    #   } elsif ($field099q eq 'Hevdet innlevert') {
    # 	$field952->add_subfields('1' => 2);
    #   }
    # }

    # 2 = Source of classification or shelving scheme
    # cn_source
    # Values are in class_source.cn_source
    # See also 942$2
    # If 096a starts with three digits we count this as dcc-based scheme
    # TODO? 
    # if ($record->field('096') && $record->field('096')->subfield('a')) {
    #   my $field096a = $record->field('096')->subfield('a');
    #   if ($field096a =~ m/^[0-9]{3,}.*/) {
    # 	$field952->add_subfields('2' => 'ddc');
    #   } else {
    # 	$field952->add_subfields('2' => 'z');
    #   }
    # }

    # 3 = Materials specified (bound volume or other part)

    # 4 = Damaged status
    # DAMAGED  	0  	
    # DAMAGED 	1 	Damaged 	 

    # 5 = Use restrictions
    # RESTRICTED  	0  	
    # RESTRICTED 	1 	Restricted Access
    # TODO? None are restricted

    # 6 = Koha normalized classification for sorting

    # 7 = Not for loan	
    # Status of the item, connect with the authorised values list 'NOT_LOAN'
    # 099x Gallrad ('SCRAPPED')
    if (my $field099x = $field099->subfield('x')) {
      if ($field099x eq "SCRAPPED") {
        $field952->add_subfields('7' => 3);
      }
    }

    # 8 = Collection code	
    # CCODE
    # TODO? 

    # 9 = Koha itemnumber (autogenerated)

    # Add this field 952 to the record
    $record->append_fields($field952);

  }

  # 2. MOVE DATA FROM NON-NORMARC TO NORMARC FIELDS?

  # 3. DELETE NON-NORMARC FIELDS

  # $record = remove_field($record, '005');
  # $record = remove_field($record, '096');
  $record = remove_field($record, '099');	

  return $record;

}

1;
