#!/usr/bin/perl
use strict;
use HTML::FormEngine;
use CGI;

my $q = CGI->new;
print $q->header,
      $q->start_html('FormEngine example: Hobbies');
my $Form = HTML::FormEngine->new(scalar $q->Vars);
my $msg = '';
my @form = (
	{
	  templ => 'check',
	  NAME  => [['hobbies1','hobbies2'],['hobbies3','hobbies4'],['hobbies5','hobbies6'],'hobbies7','hobbies8'],
	  TITLE => 'hobbies',
	  OPTION => [['Parachute Jumping', 'Playing Video Games'], ['Doing Nothing', 'Soak'], ['Head Banging', 'Cat Hunting'], "Don't Know", '<&emb_text&>'],
	  OPT_VAL => [[1,2], [3,4], [5,6], 7, 8],
	  VALUE => [1,2,7],
          'sub' => {'emb_text' => {'NAME' => 'Other', 'VALUE' => ''}},
	  ERROR => sub{if(shift eq 4) { return "That's not a faithfull hobby!" }}
	}
);			

$Form->conf(\@form);
$Form->make();
if($Form->ok){
  print "Thank you!";
}
else {
  $Form->print;
}
print $q->end_html;