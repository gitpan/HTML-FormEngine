
=head1 NAME

HTML::FormEngine::Skin - FormEngines default skin

=head1 THE TEMPLATE SYSTEM

=head2 Variables

Variables must have the following format:

<&[A-Z_]+&>

When the template is processed these directives are replaced
by the variables value. If no value was defined, the default value is used, if
even this is missing, they're just removed.

=head2 Handler calls

You can call a handler out of an template and so replace the call directive with the
handlers return value. Handler calls must
have the following format:

<&[a-z_]+( ((?!<&|&>)..)*.?)?&>

The first part is the name of the handler or the template, the
second part is optional, it can be used to pass arguments to the handler.
So C<<&error ERROR_IN&>> calls the error handler and passes to it
ERROR_IN as argument. Mostly handlers are called with out any arguments,
e.g. C<<&value&>>, which calls the value handler.

The handlers are defined in Handler.pm and registered in Config.pm.
The default handler is used for processing templates. So if you want
to nest templates, you might use the templates name as a handler name
and so call the default handler which will return the processed template
code.

For more information about handlers, see the pod 
documentation of Handler.pm.

=head2 Loops

If you want to repeat a certain template fragment several times, you
can use the following notation:

<~some lines of code~LOOPVARIABLES SEPERATED BY SPACE~>

If one or more loop variables are array references, the loop is repeated until
the last loop variable as no element left. If all loop variables are scalars, the code
is only printed once. If one ore more, but not all loop variables are scalars, these scalar
variables have in every repition the same value. If a loop variable is an array reference, but has
no elements left, it has the NULL value in the following repitions.

You can nest loops. For example the I<text> template uses this feature: If you use one dimensional arrays,
the text fields are printed each on a single line, if you use two dimensional arrays, you can print several
text fields on the same line.

=cut

######################################################################

package HTML::FormEngine::Skin;

$skin{main} = '
<form action="<&ACTION&>" method="<&METHOD&>">
<table border=0 align="center" summary=""><~
<tr><&TEMPL&></tr>~TEMPL~>
<tr>
   <td align="right" colspan=3>
      <input type="submit" value="<&SUBMIT&>" name="<&FORMNAME&>" />
   </td>
</tr>
</table>
</form>
';

$skin{confirm} = '
<form action="<&ACTION&>" method="<&METHOD&>">
<&CONFIRMSG&><br><br>
<input type="hidden" name="<&FORMNAME&>" value="1" />
<table border=0 align="center" summary=""><~
<tr><&TEMPL&></tr>~TEMPL~>
<tr>
   <td align="left">
     <input type="submit" name="<&CONFIRM_CANCEL&>" value="<&CANCEL&>">
   </td>
   <td align="right" colspan=2>
      <input type="submit" value="<&SUBMIT&>" name="<&CONFIRMED&>" />
   </td>
</tr>
</table>
</form>
';
  
$skin{text} = '
   <td valign="top"><&TITLE&></td>
   <td>
      <table border=0 cellspacing=0 cellpadding=0 summary=""><~
        <tr><~
          <td valign="top">
            <table border=0 cellspacing=0 cellpadding=0 summary="">
              <tr>
                <td><&SUBTITLE&></td>
                <td>
                  <input type="<&TYPE&>" value="<&value&>" name="<&NAME&>" maxlength="<&MAXLEN&>" size="<&SIZE&>" /><br/>
                </td>
              </tr>
              <tr><td></td><td style="color:#FF0000"><&error ERROR_IN&></td></tr>
            </table>
          </td>~NAME VALUE MAXLEN SIZE SUBTITLE ERROR_IN~>
        </tr>~NAME VALUE MAXLEN SIZE SUBTITLE ERROR_IN~>
      </table>
   </td>
   <td style="color:#FF0000" valign="bottom"><&error&></td>
';

$skin{radio} = '
   <td valign="top"><&TITLE&></td>
   <td>
      <table border=0 summary=""><~
        <tr><~
          <td><input type="radio" value="<&OPT_VAL&>" name="<&NAME&>" <&checked&> /><&OPTION&></td>~OPTION OPT_VAL NAME~>
        </tr>~OPTION OPT_VAL NAME~>
      </table>
   </td>
   <td style="color:#FF0000" valign="bottom"><&error&></td>
';

$skin{select} = '
   <td valign="top"><&TITLE&></td>
   <td>
      <select size="<&SIZE&>" name="<&NAME&>"><~
        <option value="<&OPT_VAL&>" <&checked selected&>><&OPTION&></option>~OPTION OPT_VAL~>
      </select>
   </td>
   <td style="color:#FF0000" valign="bottom"><&error&></td>
';

$skin{check} = '
   <td valign="top"><&TITLE&></td>
   <td>
     <table summary=""><~
       <tr><~
         <td>
           <!<input type="checkbox" value="<&OPT_VAL&>" name="<&NAME&>" <&checked&> />!OPT_VAL NAME!> <&OPTION&>
           <font style="color:#FF0000"><&error&></font>
         </td>~OPTION OPT_VAL NAME~>
       </tr>~OPTION OPT_VAL NAME~>
     </table>
   </td>
   <td valign="bottom" style="color:#FF0000"></td>
';

$skin{check_uniq} = '
   <td valign="top"><&TITLE&></td>
   <td>
     <table summary=""><~
       <tr><~
         <td>
           <!<input type="checkbox" value="<&OPT_VAL&>" name="<&NAME&>" <&checked_uniq&> />!OPT_VAL NAME!> <&OPTION&>
           <font style="color:#FF0000"><&error&></font>
         </td>~OPTION OPT_VAL NAME~>
       </tr>~OPTION OPT_VAL NAME~>
     </table>
   </td>
   <td valign="bottom" style="color:#FF0000"></td>
';

$skin{confirm_check} = '
   <td valign="top"><&TITLE&></td>
   <td>
     <table summary="" border=0 cellspacing=0 cellpadding=0><~
       <tr><~
         <td><&confirm_checked&></td>~OPTION OPT_VAL NAME~>
       </tr>~OPTION OPT_VAL NAME~>
     </table>
   </td>
   <td valign="bottom" style="color:#FF0000"></td>
';

$skin{confirm_check_uniq} = '
   <td valign="top"><&TITLE&></td>
   <td>
     <table summary="" border=0 cellspacing=0 cellpadding=0><~
       <tr><~
         <td><&confirm_checked_uniq&></td>~OPTION OPT_VAL NAME~>
       </tr>~OPTION OPT_VAL NAME~>
     </table>
   </td>
   <td valign="bottom" style="color:#FF0000"></td>
';

$skin{textarea} = '
   <td valign="top"><&TITLE&></td>
   <td><textarea name="<&NAME&>" cols="<&COLS&>" rows="<&ROWS&>"><&value&></textarea></td>
   <td style="color:#FF0000" valign="bottom"><&error&></td>
';

$skin{hidden} = '
   <td colspan=3><~
     <input type="hidden" name="<&NAME&>" value="<&value&>" />~NAME~>
   </td>
';

$skin{print} = '
   <td valign="top"><&TITLE&></td>
   <td>
     <table border=0><~
       <tr><~
         <td><&value&><input type="hidden" name="<&NAME&>" value="<&value&>" /></td>~NAME VALUE~>
       </tr>~NAME VALUE~>
     </table>
   </td>
   <td style="color:#FF0000" valign="bottom"></td>
';

$skin{default_confirm} = '
   <td valign="top"><&TITLE&></td>
   <td>
     <table border=0><~
       <tr><~
         <td><&value -&><input type="hidden" name="<&NAME&>" value="<&value ,1&>" /></td>~NAME VALUE~>
       </tr>~NAME VALUE~>
     </table>
   </td>
   <td style="color:#FF0000" valign="bottom"></td>
';

$skin{emb_text} = '
     <&TITLE&> <input type="<&TYPE&>" value="<&value&>" name="<&NAME&>" maxlength="<&MAXLEN&>" size="<&SIZE&>" /> <font style="color:#FF0000" valign="bottom"><&error&></font>
';

$skin{button} = '
   <td colspan=3>
     <table border=0><~
       <tr><~
         <td><input type="<&TYPE&>" name="<&NAME&>" value="<&TITLE&>" /></td>~NAME TITLE~>
       </tr>~NAME TITLE~>
     </table>
   </td>';

1;
