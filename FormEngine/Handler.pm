=head1 NAME

HTML::FormEngine::Handler - FormEngine template handler

=head1 HANDLERS

=cut

######################################################################

package HTML::FormEngine::Handler;

######################################################################

=head2 default

The default handler is called if the named handler doesn't exist.

With help of the default handler one can nest templates. It expects the name,
with which it was called, to be the name of an template.
It then reads in this template and processes it. The resulting code is returned.

=cut

######################################################################

sub _handle_default {
  my $self = shift;
  shift;
  my $templ = shift;
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
  my $self = shift;
  my($res, $keyvar1, $keyvar2, $keyvar3) = split(' ', $_) if $_ = shift;
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
    }
    if(ref($self->{_handle_checked}->{$name}) ne 'HASH') {
      $self->{_handle_checked}->{$name} = {};
    }
    if($self->{_handle_checked}->{$name}->{$option}) {
      $self->{i} = 0;
      shift @{$checked};
      foreach $_ (keys(%{$self->{_handle_checked}->{$name}})) {
	$self->{_handle_checked}->{$name}->{$_} = 0;
      }
    }

    $self->{_handle_checked}->{$name}->{$option} = 1;

    $input = $checked->[0];
    $self->{i} ++;
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
    return " $res";
  }
  else {
    return '';
  }
}

######################################################################

=head2 value

This handler returns the value of the field. Therefore the handler
needs to know the name of the field. The first argument is used
to tell the handler the name of the variable in which the field name is stored.
By default this is I<NAME>.

If the form wasn't submitted, the fields default value is returned.

=cut

######################################################################

sub _handle_value {
  my $self = shift;
  my $res = $self->_get_value(shift);
  if(ref($res) eq 'ARRAY') {
    return shift @{$res};
  }
  else {
    return $res;
  }
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
  my $self = shift;
  my ($keyvar, $namevar) = split(' ', shift || 'ERROR NAME');
  if(! $namevar) {
    $namevar = 'NAME';
  }
  my $templ = shift;
  if($self->is_submitted && $self->{check_error}) {
    my $check = $self->_get_var($keyvar,1);
    $check = [ $check ] if(ref($check) ne 'ARRAY');
    if(@{$check}) {
      my $value = $self->_get_value($namevar,1);
      my $name = $self->_get_var($namevar,1);
      my ($chk,$errmsg);
      foreach $chk (@{$check}) {
	if(ref($chk) ne 'CODE' && ref($self->{checks}->{$chk}) eq 'CODE') {
	  $chk = $self->{checks}->{$chk};
	}
	if(ref($chk) eq 'CODE') {
	  if($errmsg = &$chk($value, $name, $self)) {
	    $self->{errcount} ++;
	    return $errmsg;
	  }
	}
      }
    }
  }
  return '';
}

######################################################################

1;
__END__

=head1 WRITING A HANDLER

=head2 Design

In general, a handler has the following structure:

   sub myhandler {
     my($self,$args,$callname) = @_;
     my @args = split(' ', $args);
     # ... some code ... #
     return $res;
   }

C<$self> contains a reference to the FormEngine object.

C<$args> contains the arguments which were passed to the handler (see Skin.pm).

C<$callname> contains the name or synonym which was used to call the handler.
So it is possible to use the same handler for several, similar jobs.

=head2 Install

You have to edit Config.pm to make your handler available.

