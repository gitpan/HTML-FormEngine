package HTML::FormEngine::Config;

use HTML::FormEngine::Skin;
use HTML::FormEngine::Handler;
use HTML::FormEngine::Checks;

$textdomain = "/usr/share/locale";

$skin{FormEngine} = \%HTML::FormEngine::Skin::skin;

$default_skin = 'FormEngine';

$default{default} = {TITLE => '<&NAME&>', NAME => '<&TITLE&>'};
# set ACTION to $r->uri when using mod_perl!
$default{main} = {SUBMIT => 'Ok', FORMNAME => 'FormEngine', ACTION => $ENV{REQUEST_URI}, METHOD => 'post'};
$default{text} = {TYPE => 'text', SIZE => 20};
$default{radio} = {OPT_VAL => '<&OPTION&>', OPTION => '<&OPT_VAL&>'};
$default{select} = {OPT_VAL => '<&OPTION&>', OPTION => '<&OPT_VAL&>', SIZE => 1};
$default{check} = {OPT_VAL => '<&OPTION&>', OPTION => '<&OPT_VAL&>'};
$default{textarea} = {COLS => 27, ROWS => 10};
$default{emb_text} = {SIZE => 20, VALUE => '', TYPE => 'text'};

$handler{default} = \&HTML::FormEngine::Handler::_handle_default;
$handler{checked} = \&HTML::FormEngine::Handler::_handle_checked;
$handler{value} = \&HTML::FormEngine::Handler::_handle_value;
$handler{error} = \&HTML::FormEngine::Handler::_handle_error;
$handler{gettext} = \&HTML::FormEngine::Handler::_handle_gettext;

$checks{not_null} = \&HTML::FormEngine::Checks::_check_not_null;
$checks{email} = \&HTML::FormEngine::Checks::_check_email;
$checks{rfc822} = \&HTML::FormEngine::Checks::_check_rfc822;
$checks{date} = \&HTML::FormEngine::Checks::_check_date;
$checks{digitonly} = \&HTML::FormEngine::Checks::_check_digitonly;

1;
