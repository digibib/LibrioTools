# Allowed fields according to NORMARC
# TODO: Fill in all the subfields (not actually used at he moment, though)
# TODO: Allow user to select MARC21 as an option? 

sub get_allowed_fields {

  return (
    '000' => '-',
    '001' => '-',
    '007' => '-', 
    '008' => '-', 
    # 009 LOKALE KODER
    # Feltet er reservert for lokal bruk i de enkelte systemer.
    # http://www.nb.no/normarc/008-009.3.php#Lokale%20koder
    '009' => '-', 
    '010' => '-', 
    '015' => '-', 
    '019' => '-', 
    '020' => '-', 
    '022' => '-', 
    '024' => '-', 
    '025' => '-', 
    '027' => '-',
    '028' => '-',
    '030' => '-', 
    '033' => '-', 
    '040' => '-', 
    '041' => '-', 
    '043' => '-', 
    '044' => '-', 
    '045' => '-', 
    '060' => '-', 
    '074' => '-', 
    '080' => '-', 
    '082' => '-', 
    '084' => '-',
    # 09X LOKALE FELT
    # Alle felt 090 til 099 kan benyttes til lokal informasjon. 
    # Det anbefales at feltene 090-096 benyttes til lokal klassifikasjon, oppstillingssignatur etc.
    # http://www.nb.no/normarc/050-099.4.php#lokale%20felt
    '090' => '-',
    '091' => '-',
    '092' => '-',
    '093' => '-',
    '094' => '-',
    '095' => '-',
    '096' => '-',
    '097' => '-',
    '098' => '-',
    '099' => '-',
    '100' => 'abcdejqw8', 
    '110' => '-', 
    '111' => '-', 
    '130' => '-', 
    '210' => '-', 
    '222' => '-', 
    '240' => '-', 
    '245' => 'abchnpw',
    '246' => '-', 
    '250' => '-', 
    '254' => '-', 
    '255' => '-', 
    '256' => '-', 
    '260' => '-', 
    '263' => '-', 
    '270' => '-', 
    '300' => '-', 
    '306' => '-', 
    '310' => '-', 
    '350' => '-', 
    '362' => '-', 
    '440' => '-', 
    '490' => '-', 
    '500' => '-', 
    '501' => '-', 
    '502' => '-', 
    '503' => '-', 
    '505' => '-', 
    '508' => '-', 
    '510' => '-', 
    '511' => '-', 
    '512' => '-', 
    '516' => '-', 
    '520' => '-', 
    '521' => '-', 
    '525' => '-', 
    '530' => '-', 
    '531' => '-', 
    '533' => '-', 
    '538' => '-', 
    '539' => '-', 
    '546' => '-', 
    '571' => '-', 
    '572' => '-', 
    '573' => '-', 
    '574' => '-',
    # 59X LOKALE NOTER  (R)
    # Det er satt av plass til 10 forskjellige lokale noter i feltene 590 til 599. 
    # Disse feltene kan brukes fritt til lokal informasjon (f.eks. eksemplarinformasjon)
    # http://www.nb.no/normarc/500-599.5.php#lokale%20noter
    '590' => '-',
    '591' => '-',
    '592' => '-',
    '593' => '-',
    '594' => '-',
    '595' => '-',
    '596' => '-',
    '597' => '-',
    '598' => '-',
    '599' => '-',
    '600' => '-', 
    '610' => '-', 
    '611' => '-', 
    '630' => '-', 
    '640' => '-', 
    '650' => '-', 
    '651' => '-', 
    '652' => '-', 
    '653' => '-', 
    '655' => '-', 
    '656' => '-', 
    '658' => '-',
    # 69X LOKALE EMNEINNFØRSLER (R)
    # Feltene er reservert for lokal bruk i de enkelte biblioteksystemer.
    # http://www.nb.no/normarc/600-699.5.php#lokale%20emneinnf%C3%B8rsler
    '690' => '-',
    '691' => '-',
    '692' => '-',
    '693' => '-',
    '694' => '-',
    '695' => '-',
    '696' => '-',
    '697' => '-',
    '698' => '-',
    '699' => '-',
    '700' => '-', 
    '710' => '-', 
    '711' => '-', 
    '730' => '-', 
    '740' => '-', 
    '752' => '-', 
    '753' => '-', 
    '760' => '-', 
    '762' => '-', 
    '765' => '-', 
    '767' => '-', 
    '770' => '-', 
    '772' => '-', 
    '773' => '-', 
    '775' => '-', 
    '776' => '-', 
    '777' => '-', 
    '780' => '-', 
    '785' => '-', 
    '787' => '-',
    # 79X LOKALE LENKER(R)
    # Feltene er reservert for lokal bruk i de enkelte systemer. 
    # http://www.nb.no/normarc/760-79X.php#lokale%20lenker
    '790' => '-',
    '791' => '-',
    '792' => '-',
    '793' => '-',
    '794' => '-',
    '795' => '-',
    '796' => '-',
    '797' => '-',
    '798' => '-',
    '799' => '-',
    '800' => '-', 
    '810' => '-', 
    '811' => '-', 
    '830' => '-', 
    '850' => '-', 
    '856' => '-', 
    '900' => 'abcdgjqtuwxz08', 
    '910' => 'abcdgnqtuwxz0', 
    '911' => 'acdgnpqtuwxz0', 
    '930' => 'abdfgiklmnopqrswxz0', 
    '940' => 'agnpwxz0', 
    '950' => 'agqwx0',
    # 99X LOKALE HENVISNINGER (R)
    # Disse felt er reservert for lokal bruk i de enkelte systemer.
    # http://www.nb.no/normarc/900-999.5.php#lokale%20henvisninger
    '990' => '-',
    '991' => '-',
    '992' => '-',
    '993' => '-',
    '994' => '-',
    '995' => '-',
    '996' => '-',
    '997' => '-',
    '998' => '-',
    # Koha specific:
    '942' => 'acehikmns026', 
    '952' => 'abcdefghjlmnopqrstuvwxyz0123456789', 
    '999' => 'abcd'
  );

}

1;