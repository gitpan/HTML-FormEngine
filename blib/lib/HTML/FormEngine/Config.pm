package HTML::FormEngine::Config;

use Locale::gettext;

use HTML::FormEngine::Skin;
use HTML::FormEngine::Handler;
use HTML::FormEngine::Checks;

$textdomain = "/usr/share/locale";

$skin{FormEngine} = \%HTML::FormEngine::Skin::skin;

$default_skin = 'FormEngine';

#$confirmtpl = 'confirm';
#$default_confirm_skin = 'default_confirm';

$confirm_skin{default} = 'default_confirm';
$confirm_skin{main} = 'confirm';
$confirm_skin{hidden} = 'hidden';
$confirm_skin{confirm} = 'confirm';
##$confirm_skin{main} = 'main';
$confirm_skin{check} = 'confirm_check';
$confirm_skin{check_uniq} = 'confirm_check_uniq';
$confirm_skin{select} = 'confirm_check';
$confirm_skin{radio} = 'confirm_check';
$confirm_skin{button} = 'button';

#$confirm_handler{} = ;

$default{default} = {TITLE => '<&NAME&>', NAME => '<&TITLE&>'};

# set ACTION to $r->uri when using mod_perl!
$default{main} = {
		  SUBMIT => 'Ok', FORMNAME => 'FormEngine', ACTION => $ENV{REQUEST_URI}, METHOD => 'post',
                  CONFIRMSG => gettext('Are you really sure, that you want to submit the following data?'),
		  CONFIRMED => 'confirmed', CONFIRM_CANCEL => 'confirm_cancel',
		  CANCEL => gettext('Cancel')
		 };
$default{text} = {TYPE => 'text', SIZE => 20};
$default{radio} = {OPT_VAL => '<&OPTION&>', OPTION => '<&OPT_VAL&>'};
$default{select} = {OPT_VAL => '<&OPTION&>', OPTION => '<&OPT_VAL&>', SIZE => 1};
$default{check} = {OPT_VAL => '<&OPTION&>', OPTION => '<&OPT_VAL&>'};
$default{textarea} = {COLS => 27, ROWS => 10};
$default{emb_text} = {SIZE => 20, VALUE => '', TYPE => 'text'};
$default{button} = {TYPE => 'button'};

$handler{default} = \&HTML::FormEngine::Handler::_handle_default;
$handler{checked} = \&HTML::FormEngine::Handler::_handle_checked;
$handler{checked_uniq} = \&HTML::FormEngine::Handler::_handle_checked_uniq;
$handler{confirm_checked} = \&HTML::FormEngine::Handler::_handle_confirm_checked;
$handler{confirm_checked_uniq} = \&HTML::FormEngine::Handler::_handle_confirm_checked_uniq;
$handler{value} = \&HTML::FormEngine::Handler::_handle_value;
$handler{error} = \&HTML::FormEngine::Handler::_handle_error;
$handler{gettext} = \&HTML::FormEngine::Handler::_handle_gettext;

$checks{not_null} = \&HTML::FormEngine::Checks::_check_not_null;
$checks{email} = \&HTML::FormEngine::Checks::_check_email;
$checks{rfc822} = \&HTML::FormEngine::Checks::_check_rfc822;
$checks{date} = \&HTML::FormEngine::Checks::_check_date;
$checks{digitonly} = \&HTML::FormEngine::Checks::_check_digitonly;
$checks{fmatch} = \&HTML::FormEngine::Checks::_check_fmatch;
$checks{regex} = \&HTML::FormEngine::Checks::_check_regex;

1;
