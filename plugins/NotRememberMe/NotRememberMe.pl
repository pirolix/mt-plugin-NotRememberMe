package MT::Plugin::Security::OMV::NotRememberMe;
# $Id$

use strict;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = '0.01'. ($revision ? ".$revision" : '');

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2012/04281938/', # blog
    doc_link => 'lab.magicvox.net/trac/mt-plugins/wiki/NotRememberMe', # trac
    description => <<'HTMLHEREDOC',
<__trans phrase="Force disable \"Remember Me\" cookie of the session.">
HTMLHEREDOC
    registry => {
        init_request => {
            'MT::App::CMS' => \&_hdlr_init_app,
        },
        callbacks => {
            'MT::App::CMS::template_source.login_mt' => \&_hdlr_source_login_mt,
        },
    },
});
MT->add_plugin ($plugin);

### Disable the cookie of the session.
sub _hdlr_init_app {
    my ($self, $app) = @_;

    # Force turning off "Remember me" check
    if ($app->param('username') && $app->param('password')) {
        $app->param('remember', 0);
    }

    # Update the cookie to expire the browser session
    my $user_cookie = $app->cookies->{$app->user_cookie};
    if (defined $user_cookie && ($user_cookie->value =~ /::1$/)) {
        (my $value = $user_cookie->value) =~ s/::\d+$/::0/;
        $app->bake_cookie (
            -name       => $app->user_cookie,
            -value      => $value,
            -path       => $app->config->CookiePath || $app->mt_path,
        );
    }
}

### Disable the "Rmember me" checkbox in login screen.
sub _hdlr_source_login_mt {
    my ($cb, $app, $tmpl) = @_;

    # MT5.1
    my $old = qq{id="remember-me"};
    my $new = qq{$old style="display: none !important;"};
    $old = quotemeta $old;
    if ($$tmpl !~ /$old/) { # MT4.3
        $old = qq{<p};
        $new = qq{$old style="display: none !important;"};
        $old = quotemeta $old;
    }
    $$tmpl =~ s/$old/$new/;
}

1;