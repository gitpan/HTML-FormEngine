=head1 NAME

HTML::FormEngine::Handler - FormEngine template handler

=head1 HANDLERS

=cut

######################################################################

package HTML::FormEngine::Handler;

use Locale::gettext;

######################################################################

=head2 default

The default handler is called if the named handler doesn't exist.

With help of the default handler one can nest templates. It expects the name,
with which it was called, to be the name of an template.
It then reads in this template and processes it. The resulting code is returned.

=cut

######################################################################

sub _handle_default {
  my ($self,$templ) = @_;
  if(defined($templ) && defined($self->{skin}->{$templ})) {
    return $self->_parse($self->{skin}->{$templ});
  }
  return '';
}

######################################################################

=head2 checked

This handler is used in the I<select>, I<radio> and I<check> template.
It first argument is returned if the field was selected. If this
argument is not defined, I<checked> is returned. If the field wasn't
selected, NULL is returned.

The second argument is the name of the variable in which the value
of the field is defined which is submitted if the field was selected.
By default the value of this argument is I<OPT_VAL>.

The third argument contains the name of the variable in which the name
of the field is stored. With the help of this variable the submitted value
of the field is read in to be compared with the value which the field should
have if it was selected. So the handler can determine wether the field
was selected or not. By default this argument is I<NAME>.

The fourth and last argument contains the name of the variable in which 
the visible name of the field is stored.
The value of this variable is read in to distinguish selection lists. We can expect
this value to be unique in the same list.
By default this argument is I<OPTION>.

Normally the only important argument is the first one. The others can be important
if you want to change variable names.

=cut

######################################################################

sub _handle_checked {
  my($self, $caller, $res, $keyvar1, $keyvar2, $keyvar3) = @_;
  $res = 'checked' if(! $res);
  $keyvar1 = 'OPT_VAL' if(! $keyvar1);
  $keyvar2 = 'NAME' if(! $keyvar2);
  $keyvar3 = 'OPTION' if(! $keyvar3);
  
  my $checked = $self->_get_value($keyvar2);
  my $value = $self->_get_var($keyvar1, 1);
  my $input = '';
  
  if(ref($checked) eq 'ARRAY' && $self->is_submitted && $self->{use_input}) {
    my $name = $self->_get_var(($keyvar2), 1);
    my $option = $self->_get_var($keyvar3, 1);
    if(ref($self->{_handle_checked}) ne 'HASH') {
      $self->{_handle_checked} = {};
      # this hash must be cleaned before remake!!
      push @{$self->{call_before_make}}, sub { my ($self) = @_; $self->{_handle_checked} = {}; };
    }
    if(ref($self->{_handle_checked}->{$name}) ne 'HASH') {
      $self->{_handle_checked}->{$name} = {};
    }
    if($self->{_handle_checked}->{$name}->{$option}) {
      shift @{$checked};
      foreach $_ (keys(%{$self->{_handle_checked}->{$name}})) {
	$self->{_handle_checked}->{$name}->{$_} = 0;
      }
    }
    
    $self->{_handle_checked}->{$name}->{$option} = 1;
    
    $input = $checked->[0];
  }
  elsif(ref($checked) eq 'ARRAY') {
    if(grep {$_ eq $value} @{$checked}) {
      $input = $value;
    }
  }
  else {
    $input = $checked;
  }
  if($input ne '' && ($input eq $value)) {
    return $res;
  }
  else {
    return '';
  }
}

######################################################################

=head2 checked_uniq

This handler is designed for checkboxes. With checked_uniq, you only
have to define one name for all options, but you can't use this name
again.

The first argument defines the value, which should be returned if a
certain option was submitted. By default this is 'checked'.

The second argument defines the name of the variable in which the
option values are stored (default: OPT_VAL).

The third argument defines the name of the variable which defines the
field name (default: NAME).

=cut

######################################################################

sub _handle_checked_uniq {
  my($self, $caller, $res, $keyvar1, $keyvar2) = @_;
  $res = 'checked' if(! $res);
  $keyvar1 = 'OPT_VAL' if(! $keyvar1);
  $keyvar2 = 'NAME' if(! $keyvar2);
  my $checked = $self->_get_value($keyvar2);
  my $value = $self->_get_var($keyvar1, 1);
  if(ref($checked) eq 'ARRAY') {
    return $res if grep {$value eq $_} @{$checked};
  }
  else {
    return $res if($value eq $checked);
  }
  return '';
}

######################################################################

=head2 confirm_checked

This is a confirm handler. It returns the title of an option if the
option was submitted. Therefore the C<checked> handler is called, with
the option title as first argument.

The first argument defines the name of the variable in which the
option values are stored (default: OPT_VAL).  The second argument
defines the name of the variable which defines the field name
(default: NAME).

The third argument defines the name of the variable which stores the
option titles (default: OPTION).

=cut

######################################################################

sub _handle_confirm_checked {
  my ($self,$caller,$optvalvar,$namevar,$optionvar) = @_;
  $optvalvar = 'OPT_VAL' unless($optvalvar);
  $namevar = 'NAME' unless($namevar);
  $optionvar = 'OPTION' unless($optionvar);
  my $res = $self->_get_var($optionvar,1) . '<input type="hidden" name="' . $self->_get_var($namevar,1) . '" value="' . $self->_get_var($optvalvar,1) . '">';
  return _handle_checked($self,$caller,$res,$optvalvar,$namevar,$optionvar);
}

######################################################################

=head2 confirm_checked_uniq

This handler is very simalar to C<confirm_checked>. The only
difference is that it calls C<checked_uniq> instead of C<checked>.

=cut

######################################################################

sub _handle_confirm_checked_uniq {
  my ($self,$caller,$optvalvar,$namevar,$optionvar) = @_;
  $optvalvar = 'OPT_VAL' unless($optvalvar);
  $namevar = 'NAME' unless($namevar);
  $optionvar = 'OPTION' unless($optionvar);
  my $res = $self->_get_var($optionvar,1) . '<input type="hidden" name="' . $self->_get_var($namevar,1) . '" value="' . $self->_get_var($optvalvar,1) . '">';
  return _handle_checked_uniq($self,$caller,$res,$optvalvar,$namevar);
}

######################################################################

=head2 value

This handler returns the value of the field.

The first argument defines the value which should be returned if the
value is empty. By default this is undef.

If the second argument is true (1), the value, which was last returned
for this field name, will be returned again instead of trying to fetch
the next value.

The third argument is used to tell the handler the name of the
variable in which the field name is stored.  By default this is
I<NAME>.

If the form wasn't submitted, the fields default value is returned.

=cut

######################################################################

sub _handle_value {
  my ($self,$caller,$none,$same,$namevar) = @_;
  my $res = $self->_get_value($namevar);
  if(ref($res) eq 'ARRAY') {
    if($same) {
      $res = $res->[0];
    }
    else {
      $res =  shift @{$res};
    }
  }
  return ($res || $res eq '0') ? $res : $none;
}

######################################################################

=head1 error

The first argument sets the name of the variable in which the error checks are
set. By default this is I<ERROR>.

The second argument sets the name of the variable in which the fields name
is stored. By default this is I<NAME>.

The handler calls the defined error checks until an error message is returned
or all checks were called. If it retrieves an error message it returns this message,
else NULL is returned.

=cut

######################################################################

sub _handle_error {
  my ($self,$caller,$keyvar,$namevar) = @_;
  $keyvar = 'ERROR' unless($keyvar);
  $namevar = 'NAME' unless($namevar);

  my $templ = shift;
  if($self->is_submitted && $self->{check_error}) {
    my $check = $self->_get_var($keyvar,1);
    $check = [ $check ] if(ref($check) ne 'ARRAY');
    if(@{$check}) {
      my $value = $self->_get_value($namevar,1);
      my $name = $self->_get_var($namevar,1);
      if(ref($value) eq 'ARRAY') {
	if (ref($self->{_handle_error}) ne 'ARRAY') {
	  $self->{_handle_error} = {};
	  push @{$self->{do_before_make}}, sub { my($self) = @_; $self->{_handle_error} = {}; };
	}
	$value = $value->[$self->{_handle_error}->{$name}++ || 0];
      }
      my ($chk,$errmsg);
      foreach $chk (@{$check}) {
	if(ref($chk) ne 'CODE' && ref($self->{checks}->{$chk}) eq 'CODE') {
	  $chk = $self->{checks}->{$chk};
	}
	if(ref($chk) eq 'CODE') {
	  if($errmsg = &$chk($value, $name, $self)) {
	    $self->{errcount} ++;
	    return $self->_get_var('errmsg') || $errmsg;
	  }
	}
      }
    }
  }
  return '';
}

######################################################################

=head2 gettext

The arguments, given to this handler, are passed through gettext and
then joined together with a spacing blank inbetween. The resulting
string is returned.

=cut

######################################################################

sub _handle_gettext {
  my ($self,$caller) =  (shift,shift);
  my @res;
  foreach $_ (@_) {
    #if(m/^&[A-Z_]+&$/) {
    #  $_ = $self->_get_var($1);
    #}
    s/\,/,/g;
    push @res, gettext($_);
  }
  return join(' ', @res);
}

######################################################################

1;
__END__

=head1 WRITING A HANDLER

=head2 Design

In general, a handler has the following structure:

   sub myhandler {
     my($self,$callname,@args) = @_;
     # ... some code ... #
     return $res;
   }

C<$self> contains a reference to the FormEngine object.

C<$callname> contains the name or synonym which was used to call the handler.
So it is possible to use the same handler for several, similar jobs.

C<@args> contains the arguments which were passed to the handler (see Skin.pm).

=head2 Install

You have to edit Config.pm to make your handler available.

