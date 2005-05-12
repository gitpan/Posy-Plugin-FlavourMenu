package Posy::Plugin::FlavourMenu;
use strict;

=head1 NAME

Posy::Plugin::FlavourMenu - Posy plugin to make a menu of flavours.

=head1 VERSION

This describes version B<0.42> of Posy::Plugin::FlavourMenu.

=cut

our $VERSION = '0.42';

=head1 SYNOPSIS

    @plugins = qw(Posy::Core
	...
	Posy::Plugin::YamlConfig
	...
	Posy::Plugin::FlavourMenu
	...
	));
    @actions = qw(init_params
	    ...
	    head_template
	    flavour_menu_set
	    head_render
	    ...
	);

=head1 DESCRIPTION

This plugin creates a menu to let users choose a particular "flavour"
of page layout.

There is one variable filled in by this plugin that can be used within
your flavour files.  The $flow_flavour_menu variable contains the
list of links of the different flavours available on your site.

=head2 Activation

This plugin needs to be added to both the plugins list and the actions
list.  It doesn't really matter where it is in the plugins list,
just so long as you also have the Posy::Plugin::YamlConfig plugin
as well.

In the actions list, it needs to go somewhere after B<head_template>
and before B<head_render>, since the config needs to have been read,
and this needs to set values before the head is rendered.

=head2 Configuration

This expects configuration settings in the $self->{config} hash,
which, in the default Posy setup, can be defined in the main "config"
file in the data directory.

This requires the Posy::Plugin::YamlConfig plugin (or equivalent), because the
configuration variables for this plugin are not simple string values; it
expects the config values to be in a hash at
$self->{config}->{flavour_menu}

=over 

=item B<flavour_menu>

A hash containing the settings.

=over

=item B<flavours>

The list of flavours you want to offer in your menu, in the order
that you want them to be shown.

Note that for every entry in this list, there must be a corresponding
entry in the names hash.

=item B<names>

The labels to give the flavours in the menu list.

=back

=back

Example config file:

	---
	flavour_menu:
	  flavours:
	    - html
	    - top
	    - side
	    - rss
	  names:
	    html: Default
	    top: Top
	    side: Sidebar
	    rss: 'Rss Feed'

=cut

=head1 Flow Action Methods

Methods implementing actions.

=head2 flavour_menu_set

$self->flavour_menu_set($flow_state)

Sets $flow_state->{flavour_menu} (aka $flow_flavour_menu)
to be used inside flavour files.

=cut
sub flavour_menu_set {
    my $self = shift;
    my $flow_state = shift;

    my $flavour = $self->{path}->{flavour};
    my $links = $self->flavour_menu_links($flavour);

    $flow_state->{flavour_menu} = $links;

    1;
} # flavour_menu_set

=head1 Helper Methods

Methods which can be called from within other methods.

=head2 flavour_menu_links

$links = $self->flavour_menu_links($this_flavour);

Generates the list of all flavour links.
The $this_flavour variable is the name of the currently active flavour;
it won't be added to the list.

=cut
sub flavour_menu_links {
    my $self = shift;
    my $this_flavour = shift;

    if (!defined $self->{config}->{flavour_menu})
    {
	return '';
    }

    my $links  = qq{<ul class="flavour_menu">\n};

    my $item   = qq{<li class="flavour_menu_item">};
    my $url = $self->{url};
    my $path_and_filebase;
    if ($self->{path}->{type} eq 'top_category')
    {
	$path_and_filebase = '';
    }
    elsif ($self->{path}->{type} =~ /entry$/)
    {
	$path_and_filebase = $self->{path}->{file_key};
    }
    elsif ($self->{path}->{type} eq 'category')
    {
	$path_and_filebase = $self->{path}->{file_key};
	$path_and_filebase .= '/index';
    }
    elsif ($self->{path}->{type} eq 'chrono')
    {
	$path_and_filebase = $self->{path}->{info};
    }

    my $anchor = qq{<a href="$url/$path_and_filebase};
    my $end    = qq{</a></li>\n};

    # chrono seem to need to set the flavour with ?flav=flavour
    if ($self->{path}->{type} eq 'chrono')
    {
	foreach (@{$self->{config}->{flavour_menu}->{flavours}})
	{
	    my $name = $self->{config}->{flavour_menu}->{names}->{$_};
	    $links .= qq{$item$anchor?flav=$_">$name$end}
	    if (!/^$this_flavour$/);
	}
    }
    else
    {
	foreach (@{$self->{config}->{flavour_menu}->{flavours}})
	{
	    my $name = $self->{config}->{flavour_menu}->{names}->{$_};
	    $links .= qq{$item$anchor.$_">$name$end} if (!/^$this_flavour$/);
	}
    }

    $links .= qq{</ul>\n};

    return $links;
} # flavour_menu_links

=head1 INSTALLATION

Installation needs will vary depending on the particular setup a person
has.

=head2 Administrator, Automatic

If you are the administrator of the system, then the dead simple method of
installing the modules is to use the CPAN or CPANPLUS system.

    cpanp -i Posy::Plugin::FlavourMenu

This will install this plugin in the usual places where modules get
installed when one is using CPAN(PLUS).

=head2 Administrator, By Hand

If you are the administrator of the system, but don't wish to use the
CPAN(PLUS) method, then this is for you.  Take the *.tar.gz file
and untar it in a suitable directory.

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Or, if you're on a platform (like DOS or Windows) that doesn't like the
"./" notation, you can do this:

   perl Build.PL
   perl Build
   perl Build test
   perl Build install

=head2 User With Shell Access

If you are a user on a system, and don't have root/administrator access,
you need to install Posy somewhere other than the default place (since you
don't have access to it).  However, if you have shell access to the system,
then you can install it in your home directory.

Say your home directory is "/home/fred", and you want to install the
modules into a subdirectory called "perl".

Download the *.tar.gz file and untar it in a suitable directory.

    perl Build.PL --install_base /home/fred/perl
    ./Build
    ./Build test
    ./Build install

This will install the files underneath /home/fred/perl.

You will then need to make sure that you alter the PERL5LIB variable to
find the modules, and the PATH variable to find the scripts (posy_one,
posy_static).

Therefore you will need to change:
your path, to include /home/fred/perl/script (where the script will be)

	PATH=/home/fred/perl/script:${PATH}

the PERL5LIB variable to add /home/fred/perl/lib

	PERL5LIB=/home/fred/perl/lib:${PERL5LIB}

=head1 REQUIRES

    Posy
    Posy::Core
    Posy::Plugin::YamlConfig

    Test::More

=head1 SEE ALSO

perl(1).
Posy
YAML

=head1 BUGS

Please report any bugs or feature requests to the author.

=head1 AUTHOR

    Kathryn Andersen (RUBYKAT)
    perlkat AT katspace dot com
    http://www.katspace.com

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2004-2005 by Kathryn Andersen

Based in part on the 'css' blosxom plugin by
Eric Davis <edavis <at> foobargeek <dot> com> http://www.foobargeek.com
And in part on the 'flavourmenu' blosxom plugin by
Tim Lambert (lambert <at> cse <dot> unsw <dot> edu <dot> au)

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Posy::Plugin::FlavourMenu
__END__
