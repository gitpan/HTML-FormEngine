=head1 NAME

HTML::FormEngine - create,validate and control html/xhtml forms

=cut

######################################################################

package HTML::FormEngine;
require 5.004;

# Copyright (c) 2003, Moritz Sinn. This module is free software;
# you can redistribute it and/or modify it under the terms of the
# GNU GENERAL PUBLIC LICENSE, see COPYING for more information.

use strict;
use vars qw($VERSION);
$VERSION = '0.7.1';

######################################################################

=head1 DEPENDENCIES

=head2 Perl Version

	5.004

=head2 Standard Modules

	none

=head2 Nonstandard Modules

        Clone 0.13
        Hash::Merge 0.07
        Locale::gettext 1.01
        Date::Pcalc 1.2

=cut

######################################################################

use Clone qw(clone);
use Hash::Merge qw(merge);
use Locale::gettext;
require HTML::FormEngine::Config;

######################################################################

=head1 SYNOPSIS

=head2 Example Code

       #!/usr/bin/perl

       use strict;
       use CGI;
       use HTML::FormEngine;
       #use POSIX; # for setlocale
       #setlocale(LC_MESSAGES, 'german'); # for german error messages

       my $q = new CGI;
       print $q->header;

       my $Form = HTML::FormEngine->new(scalar $q->Vars);
       my @form = (
	    {
	      templ => 'select',
	      NAME => 'Salutation',
	      OPTION => ['mr.','mrs.'],
	    },
	    {
	     SIZE => 10,
	     MAXLEN => 20,
	     SUBTITLE => [['', '&nbsp;/&nbsp;']],
	     NAME => [['forname', 'surname']],
	     TITLE => 'For- / Surname ',
             ERROR_IN => 'not_null'
	    },
	    {
	      MAXLEN => 30,
	      NAME => 'Email',
	      ERROR => ['not_null', 'rfc822'] # rfc822 defines the email address standard
	    },
	    {
	     templ => 'radio',
	     TITLE => 'Subscribe to newsletter?',
	     NAME => 'newsletter',
	     OPT_VAL => [[1, 2, 3]],
	     OPTION => [['Yes', 'No', 'Perhaps']],
	     VALUE => 1
	    },
	    {
	     templ => 'check',
             OPTION => 'I agree to the terms of condition!',
             NAME => "agree",
             TITLE => '',
	     ERROR => sub{ return("you've to agree!") if(! shift); }
	    }
       );

       $Form->conf(\@form);
       $Form->make();

       print $q->start_html('FormEngine example: Registration');
       if($Form->ok){
         $Form->clear();	
	 print "<center>You've successfully subscribed!</center><br>";
       }
       print $Form->get,
             $q->end_html;

=head2 Example Output

This output is produced by FormEngine when using the example code and no data was submitted:

    <form action="/cgi-bin/FormEngine/registration.cgi" method="post">
    <table border=0 align="center" summary="">
    <tr>
       <td valign="top">Salutation</td>
       <td>
	  <select size="1" name="Salutation">
	    <option value="mr.">mr.</option>

	    <option value="mrs.">mrs.</option>
	  </select>
       </td>
       <td style="color:#FF0000" valign="bottom"></td>
    </tr>
    <tr>
       <td valign="top">For- / Surname </td>
       <td>
	  <table border=0 cellspacing=0 cellpadding=0 summary="">

	    <tr>
	      <td valign="top">
		<table border=0 cellspacing=0 cellpadding=0 summary="">
		  <tr>
		    <td></td>
		    <td>
		      <input type="text" value="" name="forname" maxlength="20" size="10" /><br/>
		    </td>
		  </tr>

		  <tr><td></td><td style="color:#FF0000"></td></tr>
		</table>
	      </td>
	      <td valign="top">
		<table border=0 cellspacing=0 cellpadding=0 summary="">
		  <tr>
		    <td>&nbsp;/&nbsp;</td>
		    <td>

		      <input type="" value="" name="surname" maxlength="20" size="10" /><br/>
		    </td>
		  </tr>
		  <tr><td></td><td style="color:#FF0000"></td></tr>
		</table>
	      </td>
	    </tr>
	  </table>
       </td>
       <td style="color:#FF0000" valign="bottom"></td>
    </tr>
    <tr>
       <td valign="top">Email</td>
       <td>
	  <table border=0 cellspacing=0 cellpadding=0 summary="">
	    <tr>
	      <td valign="top">
		<table border=0 cellspacing=0 cellpadding=0 summary="">

		  <tr>
		    <td></td>
		    <td>
		      <input type="text" value="" name="Email" maxlength="30" size="20" /><br/>
		    </td>
		  </tr>
		  <tr><td></td><td style="color:#FF0000"></td></tr>
		</table>
	      </td>

	    </tr>
	  </table>
       </td>
       <td style="color:#FF0000" valign="bottom"></td>
    </tr>
    <tr>
       <td valign="top">Subscribe to newsletter?</td>
       <td>
	  <table border=0 summary="">

	    <tr>
	      <td><input type="radio" value="1" name="newsletter" checked />Yes</td>
	      <td><input type="radio" value="2" name="newsletter" />No</td>
	      <td><input type="radio" value="3" name="newsletter" />Perhaps</td>
	    </tr>
	  </table>
       </td>
       <td style="color:#FF0000" valign="bottom"></td>
    </tr>
    <tr>
       <td valign="top"></td>
       <td>
	 <table summary="">
	   <tr>
	     <td>
	       <input type="checkbox" value="I agree to the terms of condition!" name="agree" /> I agree to the terms of condition!
	       <font style="color:#FF0000"></font>

	     </td>
	   </tr>
	 </table>
       </td>
       <td valign="bottom" style="color:#FF0000"></td>
    </tr>
    <tr>
       <td align="right" colspan=3>
	  <input type="submit" value="Ok" name="FormEngine" />
       </td>
    </tr>
    </table>
    </form>

=head1 DESCRIPTION

FormEngine.pm is a Perl 5 object class which provides an api for managing html/xhtml forms. FormEngine has its own, very flexible template system for defining form skins. A default skin is provided, it should be sufficent in most cases, but making your own isn't difficult (please send them to me!).

FormEngine also provides a set of functions for checking the form input, here too it is very easy to define your own check methods or to adapt the given.

I<gettext> is used for international error message support. So use C<setlocale(LC_MESSAGES, 'german')> if you want to have german error messages (there isn't support for any other language yet, but it shouldn't be difficult to translate the .po file, don't hesitate!).

FormEngine is designed to make extension writing an easy task!

=head1 OVERVIEW

Start with calling the C<new> method, it will return an FormEngine object. As argument you can pass a reference to an hash, which should contain the input values (calling C<set_input> is also possible). Now you should define an array or hash which contains the form configuration. Pass a reference to that hash or array to C<conf>. Now call C<make>, this will generate the html code. Next you should use C<ok> to check if the form was submitted and all input values are correct. If this is the case, you should display a success message and call C<get_input(fieldname)> for getting the value of a certain field and e.g. write it in a database. Else you should call C<get> (which will return the html form code) or C<print> which will directly print the form.

If you want the form to be always displayed, you can use C<clear> to empty it (resp. display the defaults) when the transmission was successfull.

=head1 USING FORMENGINE

The easiest way to define your form is to create an array of hash references:

    my @form = (
	    {
	      templ => 'select',
	      NAME => 'Salutation',
	      OPTION => ['mr.','mrs.'],
	    },
	    {
	     SIZE => 10,
	     MAXLEN => 20,
	     SUBTITLE => [['', '&nbsp;/&nbsp;']],
	     NAME => [['forname', 'surname']],
	     TITLE => 'For- / Surname ',
             ERROR_IN => 'not_null'
	    },
	    {
	      MAXLEN => 30,
	      NAME => 'Email',
	      ERROR => ['not_null', 'rfc822'] # rfc822 defines the email address standard
	    },
	    {
	     templ => 'radio',
	     TITLE => 'Subscribe to newsletter?',
	     NAME => 'newsletter',
	     OPT_VAL => [[1, 2, 3]],
	     OPTION => [['Yes', 'No', 'Perhaps']],
	     VALUE => 1
	    },
	    {
	     templ => 'check',
             OPTION => 'I agree to the terms of condition!',
             NAME => "agree",
             TITLE => '',
	     ERROR => sub{ return("you've to agree!") if(! shift); }
	    }
       );


This is taken out of the example above. The I<templ> key defines the field type (resp. template), the capital written keys are explained below. If I<templ> is not defined, it is expected to be C<text>.

You then pass a reference to that array to the C<conf> method like this:

       $Form->conf(\@form);

Another possibility is to define a hash of hash references and pass a reference on that to C<conf>. This is seldom needed, but has the advantage that you can define low level variables:

       my %form = (
            METHOD => 'get',
            FORMNAME => 'myform',
            SUBMIT => 'Yea! I want that!',
            'sub' => [ 
                        # Here you place your form definition (see above)
                     ] 
       );

       $Form->conf(\%form);

The meaning of the keys is explained below.
You can call C<set_main_vars> for setting low level (main) variables as well, so the hash notation isn't necessary.

=head2 The Default Skin

...knows the following field types:

=over

=item 

B<text> - text input field(s), one row

=item

B<textarea> - text input field(s), several rows

=item

B<radio> - selection list in terms of buttons (one can be selected)

=item

B<select> - selection list in terms of a pull down menu (one can be selected)

=item

B<check> - selection list in terms of buttons (several can be selected)

=item

B<hidden> - invisible field(s), can be used for passing data

=item

B<emb_text> - text field, designed to be embedded (nested) in another template (see below)

=back

=head2 Variables

Note that if you don't use the default skin, things might be diffrent. But mostly only the layout changes.
A skin which doesn't fit to the following conventiones should have its own documentation.

These Variables are always available:

=over

=item

B<NAME> - the form fields name (this must be passed to C<get_input> for getting the complying value)

=item

B<TITLE> - the displayed title of the field, by default the value of NAME

=item

B<VALUE> - the default (or initial) value of the field

=item

B<ERROR> - accepts name of an FormEngine check routine (see Config.pm and Checks.pm), an anonymous function or an reference to a named method. If an array reference is passed, a list of the above mentioned values is expected. FormEngine will then call these routines one after another until an errormessage is returned or the end of the list is reached.

=back

These variables are available for the C<text> and C<emb_text> field type only:

=over

=item

B<SIZE> - the physical length of the field (in characters) [default: 20]

=item

B<MAXLEN> - max. count of characters that can be put into the field [default: no limit]

=item

B<TYPE> - if set to I<password> for each character a I<*> is printed (instead of the character) [default: I<text>]

=back

These variables are available for all selection field types (C<radio>, C<select>, C<check>) only:

=over

=item

B<OPTION> - accepts an reference to an array with options

=item

B<OPT_VAL> - accepts an reference to an array with values for the options (by default the value of OPTION is used)

=back

These variables are available for the C<textarea> field type only:

=over

=item

B<COLS> - the width of the text input area [default: 27]

=item

B<ROWS> - the height of the text input area [default: 10]

=back

These variables are so called I<main variables> they can be set by using the hash notation (see above) or by calling C<set_main_vars> (see below):

=over

=item

B<ACTION> - the url of the page to which the form data should be submitted [default: $ENV{REQUEST_URI}, that means: the script calls itself]. Normally it doesn't make sense to change this value, but when you use mod_perl, you should set it to '$r->uri'.

=item

B<METHOD> - can be 'post' (transmit the data in HTTP header) or 'get' (transmit the data by appeding it to the url) [default: post].

=item

B<SUBMIT> - the text that should be displayed on the submit button [default: Ok]

=item

B<FORMNAME> - the string by which this form should be identified [default: FormEngine]. You must change this if you have more than one FormEngine-made form on a page. Else FormEngine won't be able to distinguish which form was submitted.

=back

B<Note>: only NAME must be set, all other variables are optional.

=head2 Methods For Creating Forms

=head3 new ([ HASHREF ])

This method is the constructor. It returns an FormEngine object.
You can pass the user input in a hash reference to it,
but you can use C<set_input> as well.

=cut

######################################################################

sub new {
  my $class = shift;
  my $self = bless( {}, ref($class) || $class);
  $self->_initialize(shift);
  $self->_initialize_child(@_);
  return $self;
}

######################################################################

=head3 set_input ( HASHREF )

To this method you must pass a reference to a hash with input values.
You can pass this hash reference to the constructor (C<new>) as well, then you don't
need this function.
If you use mod_perl you can get this reference by calling 'scalar $m->request_args'.
If you use CGI.pm you get it by calling 'scalar $q->Vars'.

=cut

######################################################################

sub set_input {
  my $self = shift;
  my $input = shift; #hashref
  if(ref($input) eq 'HASH') {
    $self->{input_copy} = $input;
    $self->{input} = clone($self->{input_copy});
  }
}

######################################################################

=head3 conf ( FORMCONF )

You have to pass the configuration of your form as array or hash reference (see above).

=cut

######################################################################

sub conf {
  my $self = shift;
  my $conf = shift;

  return ($self->{conf} = $self->_check_conf($conf));
}

######################################################################


=head3 set_main_var ( HASHREF )

You can use this method for setting the values of the I<main> template
variables (e.g. SUBMIT).
Another possibility to do that is using the hash notation when configuring
the form (see above).

=cut

######################################################################

sub set_main_vars {
  # if the array notation is used for configuration, there is no
  # other possibility to set the values of the main-template variables
  # than using this function
  my $self = shift;
  my $varval = shift; #hashref
  if(defined($varval) && ref($varval) eq 'HASH') {
    foreach $_ (keys(%{$varval})) {
      $self->{default}->{main}->{$_} = $varval->{$_};
      $self->{conf}->{$_} = $varval->{$_};
    }
  }
}

######################################################################

=head3 clear

If the form was submitted, this method simply calls C<set_use_input> and C<set_error_chk>. It
sets both to false.
If make was already called, it calls it again, so that no input is used and no error check 
is done.

=cut

######################################################################

sub clear {
  my $self = shift;
  if($self->is_submitted) {
    $self->set_use_input(0);
    $self->set_error_chk(0);
    if($self->{cont} ne '')  {
      $self->make();
    }
  }
}

######################################################################

=head3 set_error_chk ( VALUE )

Sets wether the error handler should be called or not.
Default is true (1).

=cut

######################################################################

sub set_error_chk {
  my $self = shift;
  $self->{check_error} = (shift||0);
}

######################################################################

=head3 set_use_input ( VALUE )

Sets wether the given input should be displayed in the form fields or not.
Default is true (1).

=cut

######################################################################

sub set_use_input {
  my $self = shift;
  $self->{use_input} = (shift||0);
}

######################################################################

=head3 make

Creates the html/xhtml output, but doesn't return it (see C<get> and C<print> below).
Every method call which influences this output must be called before calling make!

=cut

######################################################################

sub make {
  # this initialises the complex parsing process
  # all configuration must be done before calling make
  my $self = shift;
  $self->{nconf} = {'main' => [clone($self->{conf})]};
  $self->{varstack} = [];
  $self->{cont} = $self->_parse('<&main&>');
}

######################################################################

=head3 print

Sends the html/xhtml output directly to STDOUT. C<make> must be called first!

=cut

######################################################################

sub print {
  my $self = shift;
  print $self->{cont}, "\n";
}

######################################################################

=head3 get

Returns the html/xhtml form code in a string. C<make> must be called first!

=cut

######################################################################

sub get {
  my $self = shift;
  return $self->{cont};
}

######################################################################

=head3 ok

Returns true (1) when the form was submitted and no errors were found!
Else it returns false (0).
This method simply calls C<is_submitted> and C<get_error_count>.

=cut

######################################################################

sub ok {
 my $self = shift;
 return $self->is_submitted && ! $self->get_error_count;
}

######################################################################

=head3 get_error_count

Returns the count of errors which where found by the error handler.

=cut

######################################################################

sub get_error_count {
  my $self = shift;
  return $self->{errcount};
}

######################################################################

=head3 is_submitted

Returns true (1) if the form was submitted, false (0) if not.

=cut

######################################################################

sub is_submitted {
  my $self = shift;
  if($self->{input}->{$self->get_formname}) {
    return 1;
  }
  else {
    return 0;
  }
}

######################################################################

=head3 get_input ( FIELDNAME )

Returns the input value of the corresponding field.

=cut

######################################################################

sub get_input {
  my $self = shift;
  my $fname = shift;
  if($fname) {
    return $self->{input}->{$fname};
  }
}

sub get_input_value {
  my $self = shift;
  return $self->get_input(shift);
}

######################################################################

=head2 Methods For Configuring FormEngine

=head3 set_skin ( HASHREF )

If you want to use an alternate skin, call this method.
You have to pass a reference to the skin hash.

=cut

######################################################################

sub set_skin {
  my $self = shift;
  $self->{skin} = shift; #hashref
}

######################################################################

=head3 add_skin ( HASHREF )

If you only want to add or overwrite some templates of the current
skin, call this method.
You have to pass a reference to the hash which stores these templates.

=cut

######################################################################

sub add_skin {
  my $self = shift;
  my $add = shift;
  $self->{skin} = merge($add, $self->{skin}); #hashref
}

######################################################################

=head3 set_default ( HASHREF )

By using this method, you completly reset the default values of the
template variables. You have to pass a reference to the hash which
stores the new settings. Look at Config.pm to see the current
settings. In most cases you better call C<add_default>.

=cut

######################################################################

sub set_default {
  my $self = shift;
  $self->{default} = shift; #hashref
}

######################################################################

=head3 add_default ( HASHREF )

Pass a hash reference to this method for adding or overwriting default
values. Look at Config.pm for more information.

=cut

######################################################################

sub add_default {
  my $self = shift;
  my $add = shift; #hashref
  $self->{default} = merge($add, $self->{default});
  foreach $_ (keys(%{$self->{default}})) {
    print $_, " ", $self->{default}->{$_}, "<br>";
  }
}

######################################################################

=head3 set_handler ( HASHREF )

This method resets the handler settings. Look at Config.pm for the
default settings. If you just want to add or overwrite a handler setting, 
use C<add_handler> (see below).

=cut

######################################################################

sub set_handler {
  my $self = shift;
  $self->{handler} = shift; #hashref
}

######################################################################

=head3 add_handler ( HASHREF )

This method adds or overwrites template handlers. Look at Config.pm and
Handler.pm for more information.

=cut

######################################################################

sub add_handler {
  my $self = shift;
  my $add = shift; #hashref
  $self->{handler} = merge($add, $self->{handler});
}

######################################################################

=head3 add_checks ( HASHREF )

This method temporary adds or overwrites check routines. Look at Config.pm and
Checks.pm for more information.

=cut

######################################################################

sub add_checks {
  my $self = shift;
  my $add = shift; #hashref
  $self->{checks} = merge($add, $self->{checks}) if(ref($add) eq 'HASH');
}

######################################################################

=head2 Debug Methods

=head3 set_debug ( DEBUGLEVEL )

Sets the debug level. The higher the value the more output is printed.

=cut

######################################################################

sub set_debug {
  my $self = shift;
  $self->{debug} = shift;
}

######################################################################

=head3 get_method

Returns the value of I<main>s METHOD variable (should be I<get> or I<post>).

=cut

######################################################################

sub get_method {
  my $self = shift;
  return $self->{conf}->{METHOD} || $self->{default}->{main}->{METHOD};
}

######################################################################

=head3 get_formname

Returns the value of I<main>s FORMNAME variable. If you have several
FormEngine forms on one page, these forms mustn't have the same FORMNAME value!
You can set it with C<set_main_vars>.

=cut

######################################################################

sub get_formname {
  my $self = shift;
  return ($self->{conf}->{FORMNAME} || $self->{default}->{main}->{FORMNAME});
}

######################################################################

=head3 get_conf

Returns a reference to a hash with the current form configuration.
Changing this hash DOESN'T influence the configuration, because it
is just a copy.

=cut

######################################################################

sub get_conf {
  my $self = shift;
  return clone($self->{conf});
}

######################################################################

=head3 print_conf

Prints the current form configuration to STDOUT.

=cut

######################################################################

sub print_conf {
  my $self = shift;
  my $conf = shift;
  my $i = shift || 0;
  my $y = 0;
  if(ref($conf) eq 'ARRAY') {
    foreach $_ (@{$conf}) {
      for($y=0; $y<$i; $y++) { print " "; }
      print "ARRAY\n";
      $self->print_conf($_, $i+1);
    }
  }
  elsif(ref($conf) eq 'HASH') {
    foreach $_ (keys(%{$conf})) {
      for($y=0; $y<$i; $y++) { print " "; }
      print $_, "\n";
      $self->print_conf($conf->{$_}, $i+1);
    }
  }
  else {
    for($y=0; $y<$i; $y++) { print " "; } 
    print $conf, "\n";
  }
}
######################################################################

=head2 Special Features

=head3 nesting templates

There are two ways how you can nest templates. The first one
is to put a handler call in the template definition. This is a less flexible
solution, but it might be very usefull. See the pod documentation of Skin.pm
for more information.

The second and flexible way is, to assign a handler call to a template variable
(see the pod documentation of Skin.pm for more information about handler calls).
A good example for this way is hobbies.cgi. There you have a option called I<other>
and an input field to put in the name of this alternative hobby. When you look at
the form definition below, you see that the value of the I<OPTION> variable of this option
is simply I<<&emb_text&>>, this is a handler call. So the handler is called and its
return value (in this case the processed emb_text template) is assigned to the variable.

The form definition of hobbies.cgi:

    my @form = (
	    {
	      templ => 'check',
	      NAME  => [['hobbies[1]','hobbies[2]'],['hobbies[3]','hobbies[4]'],['hobbies[5]','hobbies[6]'],'hobbies[7]','hobbies[8]'],
	      TITLE => 'hobbies',
	      OPTION => [['Parachute Jumping', 'Playing Video Games'], ['Doing Nothing', 'Soak'], ['Head Banging', 'Cat Hunting'], "Don't Know", '<&emb_text&>'],
	      OPT_VAL => [[1,2], [3,4], [5,6], 7, 8],
	      VALUE => [1,2,7],
	      'sub' => {'emb_text' => {'NAME' => 'Other', 'VALUE' => ''}},
	      ERROR => sub{if(shift eq 4) { return "That's not a faithfull hobby!" }}
	    }
    );			

If you have a closer look at the form definition above, you'll recognize that there
is a key called 'sub'. With help of this key you can define the 
variables of the nested templates. If the nested templates don't use the same variable
names as their parents, you don't need that, because then you can assign these variables on the same
level with the parents template variables. 

=cut

######################################################################
# INTERNAL METHODS                                                   #
######################################################################

sub _initialize {
  my $self = shift;
  my $input = shift;

  bindtextdomain("HTML-FormEngine", $HTML::FormEngine::Config::textdomain);
  textdomain("HTML-FormEngine");

  Hash::Merge::set_behavior('LEFT_PRECEDENT');

  $self->{input_copy} = {};
  if(ref($input) eq 'HASH') {
    foreach (keys(%{$input})) {
      if(defined($input->{$_}) && !ref($input->{$_}) && $input->{$_} =~ m/\0/o) {
	$self->{input_copy}->{$_} = [];
	@{$self->{input_copy}->{$_}} = split("\0", $input->{$_});
      } else {
	$self->{input_copy}->{$_} = $input->{$_};
      }
    }
  }
  $self->{input} = clone($self->{input_copy});
  $self->{errcount} = 0;
  $self->{use_input} = 1;
  $self->{check_error} = 1;
  $self->{cont} = '';

  # setting up the default skin
  # use:
  #  set_skin | add_skin | set_default | add_default | set_handler | add_handler
  # to fit it to your needs or edit Config.pm

  $self->{skin} = \%HTML::FormEngine::Config::skin;
  $self->{default} = \%HTML::FormEngine::Config::default;
  $self->{handler} = \%HTML::FormEngine::Config::handler;
  $self->{checks} = \%HTML::FormEngine::Config::checks;
}

sub _initialize_child {};

sub _check_conf {
  # the array notation is more user friendly
  # here we rewrite it into the internal hash notation.
  # users are allowed to use the more flexible but also more complicated
  # hash notation directly.

  my ($self,$conf) = @_;
  my (%cache, $templ);
  my $tmp;

  if(ref($conf) eq 'ARRAY' && ref($conf->[0]) eq 'HASH') {
    %cache = ();
    $cache{'sub'} = {};
    $cache{'TEMPL'} = [];
    foreach $_ (@{$conf}) {
      $templ = $_->{templ}||'text';
      delete $_->{templ};
      push @{$cache{'TEMPL'}}, "<&$templ&>";
      if(ref($cache{sub}->{$templ}) ne 'ARRAY') {
	$cache{sub}->{$templ} = [];
      }
      push @{$cache{sub}->{$templ}}, $self->_check_conf($_);
    }
    $conf = \%cache;
  }
  elsif(ref($conf) eq 'HASH' && ref($conf->{sub}) eq 'HASH') {
    foreach $_ (keys(%{$conf->{sub}})) {
      if(ref($conf->{sub}->{$_}) eq 'HASH') {
	$conf->{sub}->{$_} = [$self->_check_conf($conf->{sub}->{$_})];
      }
      elsif(ref($conf->{sub}->{$_}) eq 'ARRAY') {
	foreach $_ (@{$conf->{sub}->{$_}}) {
	  $_ = $self->_check_conf($_) if(ref($_) eq 'HASH');
	}
      }
    }
  }
  elsif(ref($conf) eq 'HASH' && ref($conf->{sub}) eq 'ARRAY') {
    $tmp = $self->_check_conf($conf->{sub});
    $conf->{sub} = $tmp->{sub};
    $conf->{TEMPL} = $tmp->{TEMPL};
  }
  return $conf;
}

sub _get_var {
  # here we go through the variable stack (from highest to lowest level)
  # we break out of the loop if a value was found.
  # we then delete this value except the second argument ($notdelete) is true or
  # 'persistent' is defined on that level.
  # 'persistent' is used to make a default-value-level on which the higher
  # level will go back if there is no value defined for a certain variable

  my $self = shift;
  my $var = shift;
  my $notdelete = (shift||0);
  my $value = '';
  my $i;
  for($i=@{$self->{varstack}} - 1; $i>=0; $i--) {
    if(defined($self->{varstack}->[$i]->{$var})) {
      $value = $self->{varstack}->[$i]->{$var};
      if(! $notdelete && ! defined($self->{varstack}->[$i]->{'persistent'})) {
	delete $self->{varstack}->[$i]->{$var};
      }
      last;
    }
  }
  return $value;
}

sub _set_var {
  # this function sets an (variable,value) pair on the current stack level
  # it is needed when we go through an array
  my $self = shift;
  my $var = shift;
  my $value = shift;
  my $i=@{$self->{varstack}} -1;
  if($self->{debug}) {
    print "$var => $value\n";
  }
  $self->{varstack}->[$i]->{$var} = $value;
}

sub _parse {
  # here the templates are parsed into one resulting form, due to the given configuration
  # this job is realized by calling _parse recursive
  my $self = shift;
  my $cont = shift;
  my $nconf_back = {};
  my (%itvars, $itval, $max, $i);
  my ($handler, $templ, $args, $val, $tmp, $body, $pupo);
  my ($cache,$default);

  # parsing handler calls, we mustn't touch <~ ~> blocks
  while($cont =~ m/^(?:(?:.*<~.*~>.*)*|(?:(?!.*<~.*).*))<&([a-z_]+)(?: ((?:(?!<&|&>)..)*.?))?&>/so) {
  ##while($cont =~ m/^(?=.*<~.*~>.*).*|(?!.*<~.*).*<&([a-z_]+)(?: ((?:(?!<&|&>)..)*.?))?&>/s) {
    $templ = $1;
    $args = $2;
    $nconf_back = $self->{nconf};
    
    if(ref($self->{nconf}->{$templ}) eq 'ARRAY' && ref($self->{nconf}->{$templ}->[0]) eq 'HASH') {
      # define new nconf
      # in nconf we store the subtemplate definitions
      if(ref($self->{nconf}->{$templ}->[0]->{sub}) eq 'HASH') {
	# do a merge so that the previous definitions are still known (we append them)
	$self->{nconf} = merge($self->{nconf}->{$templ}->[0]->{sub}, $self->{nconf});
      }
      
      # soon we will store the definitions for the found subtemplate on the variable stack.
      # sub isn't a variable, behind this key the subsubtemplate definitions are stored, these
      # we allready extracted above.
      # so we now delete this key to prevent it from being pushed on the variable stack.
      if(defined($nconf_back->{$templ}->[0]->{sub})) {
	delete $nconf_back->{$templ}->[0]->{sub};
      }
      
      # using the default settings
      if(ref($self->{default}->{default}) eq 'HASH' || ref($self->{default}->{$templ}) eq 'HASH') {
	$cache = shift @{$nconf_back->{$templ}};
	# go through
	if(! (ref($self->{default}->{$templ}) eq 'HASH')) {
	  $default = $self->{default}->{default};
	}
	elsif(! (ref($self->{default}->{default}) eq 'HASH')) {
	  $default = $self->{default}->{$templ};
	}
	else {
	  $default = merge($self->{default}->{$templ},$self->{default}->{default});
	}
	foreach $_ (keys(%{$default})) {
	  # set missing definitions
	  if(! defined($cache->{$_}) && defined($default->{$_})){
	    # special case: copy the definition of another variable
	    if($default->{$_} =~ m/^<&([A-Z_]+)&>$/) {
	      if(ref($cache->{$1}) eq 'ARRAY') {
		$cache->{$_} = clone($cache->{$1});
	      }
	      else {
		$cache->{$_} = $cache->{$1};
	      }
	    }
	    else {
	      $cache->{$_} = $default->{$_};
	    }
	  }
	}
	# push the completed definitions
	$pupo = $self->_push_varstack($cache);
      }
      else {
	# no defaults
	$pupo = $self->_push_varstack(shift @{$nconf_back->{$templ}});
      }
    }
    else {
      # no definition for this subtemplate, use defaults
      if(ref($self->{default}->{$templ}) eq 'HASH') {
	$pupo = $self->_push_varstack($self->{default}->{$templ});
      }
      else {
	# no definitions at all
	$pupo = 0;
      }
    }
    
    # set handler
    if(! ($handler = $self->{handler}->{$templ})) {
      $handler = $self->{handler}->{default}
    }
    # the following causes an segfault:
    # $cont =~ s/<&$templ&>/&$handler($self,$templ)/e;
    # this works:
    $_ = &$handler($self,$args,$templ);
    # replace subtemplate with result
    
    if($args) {
      $cont =~ s/^((.*<~.*~>.*)*|((?!.*<~.*).*))<&$templ $args&>/$1.$_/esg;
    }
    else {
      $cont =~ s/^((.*<~.*~>.*)*|((?!.*<~.*).*))<&$templ&>/$1$_/sg;
    }
    
    $self->{nconf} = $nconf_back;
    # pop as many as there were pushed before
    $self->_pop_varstack($pupo);
  }
  
  # parsing <~ ... ~VAR~> loop-blocks  
  while($cont =~ m/<~((?:(?:(?:(?!<~|~>)..)*.?<~(?:(?!<~|~>)..)*.?~>(?:(?!<~|~>)..)*.?)+)|(?:(?:(?!<~)..)*.?))~([A-Z_ ]+)~>/so) {
    undef %itvars;
    $max = 0;
    # fetch values of block variables, set max
    foreach $_ (split(' ', $2)) {
      $itval = $self->_get_var($_);
      if(ref($itval) eq 'ARRAY' && @{$itval} > 0) {
	$itvars{$_} = $itval;
	if(@{$itval} > $max) {
	  $max = @{$itval};
	}
      }
      elsif(defined($itval)) {
	$itvars{$_} = $itval;
	if($max < 1){
	  $max = 1; 
	}
      }
    }
    $tmp = '';
    $body = $1;
    for($i=0; $i<$max; $i++) {
      # set block variables to current element
      foreach $_ (keys(%itvars)) {
	if(ref($itvars{$_}) eq 'ARRAY') {
	  $self->_set_var($_, shift @{$itvars{$_}});
	  # delete a variable which elements are consumed
	  if(@{$itvars{$_}} eq 0) {
	    delete $itvars{$_};
	  }
	}
	# scalars aren't consumed
	else {
	  $self->_set_var($_, $itvars{$_});
	}
      }
      # parse and append
      $tmp .= $self->_parse($body);
    }
    # replace block with result
    $cont =~ s//$tmp/e;
  }

  # replace variables with theire values
  while($cont =~ m/<&(~)?([A-Z_]+)&>/) {
    $cont =~ s//$self->_parse($self->_get_var($2,$1))/e;
  }
  
  return $cont;
}

sub _push_varstack {
  my $self = shift;
  my $add = shift;
  my $res = 0;
  my $i;
  my %cache;
  if(ref($add) eq 'HASH') {
    if(ref($add->{default}) eq 'HASH') {
      # the 'default' key appends an default level to the stack
      %cache = %{$add->{default}};
      # the persistent key marks that level as a default level
      # variable,value pairs on a default level aren't deleted when fetched
      $cache{persistent} = 1;
      $res += $self->_push_varstack(\%cache);
      delete $add->{default};
    }
    if($self->{debug}) {
      foreach $_(keys(%{$add})) {
	for($i=0; $i<@{$self->{varstack}}; $i++) {
	  print " ";
	}
	print "$_:", $add->{$_}, "\n";
      }
    }
    push @{$self->{varstack}}, $add;
    $res ++;
  }
  return $res;
}

sub _pop_varstack {
  my $self = shift;
  my $howmany = shift;
  my $i;
  for($i=0; $i<$howmany; $i++) {
    if($self->{debug}) {
      print "rm\n";
    }
    pop @{$self->{varstack}};
  }
  return $i;
}

 
sub _get_value {
  my $self = shift;
  my $res;
  my ($keyvar1, $keyvar2) = split(' ', (shift||'NAME VALUE'));
  my $force = (shift || 0);

  if(! defined($keyvar2)){
    $keyvar2 = 'VALUE';
  }
  if(($self->is_submitted && $self->{use_input}) || $force) {
    $res = $self->{input_copy}->{$self->_get_var($keyvar1, 1)};
  }
  else {
    $res = $self->_get_var($keyvar2, 1);
  }

  if(defined($res)) {
    return $res;
  }
  else {
    return '';
  }
}

######################################################################

return 1;
__END__

=head1 EXTENDING FORMENGINE

=head2 Modify A Skin

To modify the current skin, use the method C<add_skin> (see above). You should
have a look at Skin.pm and read its pod documentation.

=head2 Write A New Skin

Have a look at Skin.pm for this task. You can easily change the layout
by copying the skin hash, fitting the html code to your needs and then using
C<set_skin> (see above) to overwrite the default.
Please send me your skins.

=head2 Write A Handler

Look at the pod documentation of Handler.pm. You can use C<add_handler> to 
add your handler temporary, edit Config.pm to make it persistent.

=head2 Write A Check Routine

The design of a check routine is explained in the pod documentation of Checks.pm.
You can easily refer to it by reference or even define it in line as an anonymous function (see
the ERROR template variable).
If your new written routine is of general usage, you should make it part of FormEngine by placing
it in Checks.pm and refering to it in Config.pm. Please send me such methods!

=head1 MORE INFORMATION

Have a look at ...

=over

=item

the pod documentation of Skin.pm for information about FormEngines template system.

=item

the pod documentation of Handler.pm for information about FormEngines handler architecture.

=item

the pod documentation of Checks.pm for information about FormEngines check methods.

=item

Config.pm for the default configuration.

=back

=head1 BUGS

Send bug reports to: moritz@freesources.org

Thanks!

=head1 AUTHOR

(c) 2003, Moritz Sinn. This module is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (see http://www.gnu.org/licenses/gpl.txt) as published by
    the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

    This module is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

I am always interested in knowing how my work helps others, so if you put this module to use in any of your own code then please send me the URL. Also, if you make modifications to the module because it doesn't work the way you need, please send me a copy so that I can roll desirable changes into the main release.

Address comments, suggestions, and bug reports to moritz@freesources.org. 
