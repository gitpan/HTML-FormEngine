=head1 NAME

HTML::FormEngine::Checks - collection of FormEngine check routines

=head1 CHECK ROUTINES 

=cut

######################################################################

package HTML::FormEngine::Checks;

use Locale::gettext;
use Date::Pcalc qw(check_date);

######################################################################

=head2 not_null

Returns I<value missing> if the field wasn't filled.

=cut

######################################################################

sub _check_not_null {
  if(shift eq '') {
    return gettext('value missing').'!';
  } 
}

######################################################################

=head2 check_email

Returns I<invalid> if the format of the field value seems to be
incompatible to an email address. Here a simple regular expression 
is used, which so far matches the common email addresses. But it isn't
compatible to any standard. Use C<rfc822> if you want to check for RFC
compatible address format. The problem with rfc is, that some working
addresses don't fit to it, though these are very rare

Here is the used regexp, please inform me if you discover any bugs:

C<^[A-Za-z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$>

=cut

######################################################################

sub _check_email {
  my ($value) = @_;
  return '' unless($value);
  # better use rfc822!
  if(! ($value =~ m/^[A-Za-z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/)) {
    return gettext('invalid').'!';
  }  
}

######################################################################

=head2 rfc822

Returns I<rfc822 failure> if the given field value doesn't match the RFC 822
specification. In RFC 822 the format of valid email addresses is defined.
This check routine is somewhat better than I<email>, the only disadvantage
is, that some working email addresses don't fit to RFC 822. So if you get
problems try using the <email> routine.

I copied this routine from http://www.cpan.org/authors/Tom_Christiansen/scripts/ckaddr.gz!

=cut

######################################################################

sub _check_rfc822 {
    # ck822 -- check whether address is valid rfc 822 address
    # tchrist@perl.com
    #
    # pattern developed in program by jfriedl; 
    # see "Mastering Regular Expressions" from ORA for details

    # this will error on something like "ftp.perl.com." because
    # even though dns wants it, rfc822 hates it.  shucks.

    my $hispass = shift;
    local $_;

    my $is_a_valid_rfc_822_addr = '';

    while (<DATA>) {
	chomp;
	$is_a_valid_rfc_822_addr .= $_;
    } 
    return 'rfc822 ' . gettext('failure') unless $hispass =~ /^${is_a_valid_rfc_822_addr}$/o;
    return '';
}

######################################################################

=head2 date

Returns I<invalid> if the field value seems to be incompatible to common
date formats or the date doesn't exist in the Gregorian calendar.
The following formats are allowed:

dd.mm.yyyy dd-mm-yyyy dd/mm/yyyy
yyyy-mm-dd yyyy/mm/dd yyyy.mm.dd

The C<check_date> method of the I<Date::Pcalc> package is used to prove
the dates existence.

=cut

######################################################################

sub _check_date {
  my $value = shift;
  return '' unless($value);
  my ($d, $m, $y);
  my $msg = gettext('invalid').'!';

  #  dd.mm.yyyy dd-mm-yyyy dd/mm/yyyy
  if($value =~ m/^([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{2,4})$/ || $value =~ m/^([0-9]{2})-([0-9]{2})-([0-9]{2,4})$/ || $value =~ m/^([0-9]{2})\/([0-9]{2})\/([0-9]{2,4})$/) {
    $d = $1;
    $m = $2;
    $y = $3;
  }
  #  yyyy-mm-dd yyyy/mm/dd yyyy.mm.dd
  elsif($value =~ m/^([0-9]{4})-([0-9]{2})-([0-9]{2})$/ || $value =~ m/^([0-9]{4})\/([0-9]{2})\/([0-9]{2})$/ || $value =~ m/^([0-9]{4}).([0-9]{2}).([0-9]{2})$/) {
    $d = $3;
    $m = $2;
    $y = $1;
  }
  else {
    return $msg;
  }

  if(! check_date($y, $m, $d)) {
    return $msg;
  }

  return '';
}

######################################################################

=head2 digitonly

... returns I<invalid> if the value doesn't match '[0-9]*'.

=cut

######################################################################

sub _check_digitonly {
  $_ = shift;
  return gettext('invalid').'!' unless(m/^[0-9]*$/);
  return 0;
}

######################################################################

=head2 fmatch

... requires the special variable I<fmatch>. This variable must
contain the name of another field. The value of this field is read in
and compared with the current value, I<doesn't match> is returned if
this fails.

When using the same fields several times, you must also define
I<ROWNUM>, this must start with 1 increased by one whenever the field
names are repeated.

B<Note:> When you defined several tables, you must reference other
fields with I<tablename.fieldname>!

=cut

######################################################################

sub _check_fmatch {
  my($value,$field,$self) = @_;
  my $match = $self->_get_var('fmatch');
  if($match) {
    $_ = $match;
    my $match = $self->get_input_value($match);
    print STDERR "no such field: $_" and return '' unless(defined($match));
    if(ref($match) eq 'ARRAY' and $_ = $self->_get_var('ROWNUM',1)) {
      $match = $match->[$_-1];
    }
    return gettext('doesn\'t match') . '!' if(defined($value) and $value ne $match);
  }
}

######################################################################

=head2 regex

... requires the special variable I<regex>, it must contain a valid
regular expression. If the value doesn't match this regex, I<invalid>
is returned. 

=cut

######################################################################

sub _check_regex {
  my($value,$field,$self) = @_;
  my $regex = $self->_get_var('regex');
  #print STDERR $regex, " ", $value, "\n";
  if($regex) {
    return gettext('invalid').'!' unless(defined($value) and ($value =~ m/$regex/));
  }
  return '';
}

######################################################################

1;

=head1 WRITING A CHECK ROUTINE

=head2 Design

In general, a check routine has the following structure:

  sub mycheck {
    my($value,$name,$self) = @_;
    #some lines of code#
    return gettext('My ErrorMessage');
  }

C<$value> contains the submitted field value.
C<$name> contains the fields name.
C<$self> contains a reference to the FormEngine object.

B<Note:> you can define the error message by yourself with the variable I<errmsg>!

=head2 Install

If your routine does a general job, you can make it part of FormEngine. Therefore just
add the routine to this file and refer to it from I<Config.pm>. Please send me such
routines.

=head1 ERROR MESSAGE TRANSLATIONS

The translations of the error messages are stored in I<FormEngine.po> files. Calling
I<msgfmt> translates these in I<FormEngine.mo> files. You must store these FormEngine.mo files in your
locale directory, this should be I</usr/share/locale>, if it isn't, you must change the value
of C<$textdomain> in Config.pm.

Provided that a translation for I<yourlanguage> exists, you can call C<setlocale(LC_MESSAGES, 'yourlanguage')> in your script to have the FormEngine error message in I<yourlanguage>.

=cut

# don't touch this stuff down here or you'll break the rfc822 matcher.
# copied from http://www.cpan.org/authors/Tom_Christiansen/scripts/ckaddr.gz
__DATA__
(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n
\015()]|\\[^\x80-\xff])*\))*\))*(?:(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\
xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"(?:[^\\\x80-\xff\n\015"
]|\\[^\x80-\xff])*")(?:(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xf
f]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*\.(?:[\040\t]|\((?:[
^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\
xff])*\))*\))*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;
:".\\\[\]\000-\037\x80-\xff])|"(?:[^\\\x80-\xff\n\015"]|\\[^\x80-\xff])*"))
*(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\
n\015()]|\\[^\x80-\xff])*\))*\))*@(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\
\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*(?:[^(\04
0)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-
\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])(?:(?:[\040\t]|\((?
:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80
-\xff])*\))*\))*\.(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\(
(?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*(?:[^(\040)<>@,;:".\\\[\]
\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\
\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\]))*|(?:[^(\040)<>@,;:".\\\[\]\000-\0
37\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"(?:[^\\\x80-\xf
f\n\015"]|\\[^\x80-\xff])*")(?:[^()<>@,;:".\\\[\]\x80-\xff\000-\010\012-\03
7]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\
\[^\x80-\xff])*\))*\)|"(?:[^\\\x80-\xff\n\015"]|\\[^\x80-\xff])*")*<(?:[\04
0\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]
|\\[^\x80-\xff])*\))*\))*(?:@(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x
80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*(?:[^(\040)<>@
,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]
)|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])(?:(?:[\040\t]|\((?:[^\\
\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff
])*\))*\))*\.(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^
\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*(?:[^(\040)<>@,;:".\\\[\]\000-
\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-
\xff\n\015\[\]]|\\[^\x80-\xff])*\]))*(?:(?:[\040\t]|\((?:[^\\\x80-\xff\n\01
5()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*,(?
:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\0
15()]|\\[^\x80-\xff])*\))*\))*@(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^
\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*(?:[^(\040)<
>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xf
f])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])(?:(?:[\040\t]|\((?:[^
\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\x
ff])*\))*\))*\.(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:
[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*(?:[^(\040)<>@,;:".\\\[\]\00
0-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x8
0-\xff\n\015\[\]]|\\[^\x80-\xff])*\]))*)*:(?:[\040\t]|\((?:[^\\\x80-\xff\n\
015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*)
?(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000
-\037\x80-\xff])|"(?:[^\\\x80-\xff\n\015"]|\\[^\x80-\xff])*")(?:(?:[\040\t]
|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[
^\x80-\xff])*\))*\))*\.(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xf
f]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*(?:[^(\040)<>@,;:".\
\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"(?:
[^\\\x80-\xff\n\015"]|\\[^\x80-\xff])*"))*(?:[\040\t]|\((?:[^\\\x80-\xff\n\
015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*@
(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n
\015()]|\\[^\x80-\xff])*\))*\))*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff
]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\
]]|\\[^\x80-\xff])*\])(?:(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\
xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*\.(?:[\040\t]|\((?
:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80
-\xff])*\))*\))*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@
,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff
])*\]))*(?:[\040\t]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff]|\((?:[^\\\x8
0-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*>)(?:[\040\t]|\((?:[^\\\x80-\xff\n\
015()]|\\[^\x80-\xff]|\((?:[^\\\x80-\xff\n\015()]|\\[^\x80-\xff])*\))*\))*
