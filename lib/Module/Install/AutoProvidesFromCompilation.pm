package Module::Install::AutoProvidesFromCompilation;
use strict;
use warnings;
use base qw/Module::Install::Base/;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

use FindBin ();
use lib ();
use File::Find ();

my $get_packages_compiled_from_file_in_dir = sub {
    my ($file, $dir) = @_;
    my %packages;

    local $@;
    eval {
        my $id = B::Hooks::OP::Check::StashChange::register(sub {
            my ($new, $old) = @_;
            my $file = B::Compiling::PL_compiling()->file;

            return unless $file =~ s/^$dir/lib/;
            
            $packages{$new} ||= $file
                unless $new eq __PACKAGE__;
        });

        require $file;
    };
    
    return %packages;
};

sub auto_provides_from_compilation {
    my $self = shift;

    return unless $Module::Install::AUTHOR;
    require Module::Find;
    require B::Hooks::OP::Check::StashChange;
    require B::Compiling;

    my $libdir = "$FindBin::Bin/lib";

    local @INC = @INC;
    lib->import($libdir);

    my %packages;
    File::Find::find(sub {
        return unless $File::Find::name =~ /\.pm$/;
        %packages = (%packages, $get_packages_compiled_from_file_in_dir->($File::Find::name, $libdir));
    }, $libdir);;

    no strict 'refs';
    $self->provides($_ => {
        file => $packages{$_},
        # This is a crappy way of doing this. FIXME
        ${$_.'::VERSION'} ? ( version => $_->VERSION() ) : ()
    }) for keys %packages;
}

1;

=head1 NAME

Module::Install::AutoProvidesFromCompilation - Automatically add provides metadata by compiling your dist.

=head1 SYNOPSIS

    use inc::Module::Install;
    name 'Example';
    all_from 'lib/Example.pm'
    auto_provides_from_compilation();
    WriteAll;

=head1 DESCRIPTION

Ensures that the META.yml generated in your distribution contains information for
every class in your C<lib/> directory. This is useful for distributions using
L<MooseX::Declare> for example, as the C<class> and C<role> keywords are not
recognised by the PAUSE indexer.

This module is an author-side extension, and acts as a no-op for users installing
one of your dists.

=head1 WARNING

This module should be considered B<HIGHLY EXPERIMENTAL>. Please check that the META.yml
generated looks sane before sending your distribution to CPAN!

=head1 METHODS

=head2 auto_provides_from_compilation

Takes no arguments, works the magic.. Call it before you call C<WriteAll()>.

=head1 HOW IT WORKS

L<B::Hooks::OP::Check::StashChange> is used to hook the perl compiler. Every .pm file
in your distribution is compiled and when the stash code is being compiled in is changed,
the filename being compiled is found by L<B::Compiling>.

When all the dependencies for your distributon as installed, this is theoretically a
foolproof way of working out the correct set of packages.

However, we get notifed of B<all> the packages compiled (including your modules
dependencies), which could result in claiming to provide things which are not
actually part of your module, and a broken distribution.

Just to be crystal clear on that: B<PLEASE CHECK YOUR GENERATED META.yml, AS DEMONS
FLYING OUT OF YOUR NOSE MAY OFFEND>.

You have been warned.

=head1 SEE ALSO

L<Module::Install::ProvidesClass> - PPI based solution to the same issue.

=head1 BUGS

Almost certainally. There are exactly no tests for this code right now.

Patches (or just pointing me at distributions which don't play nicely with this
extension) welcome.

=head1 AUTHOR

    Tomas Doran (t0m) <bobtfish@bobtfish.net>

=head1 COPYRIGHT

Copyright (C) 2009 Tomas Doran

=head1 LICENSE

This software is licensed under the same terms as perl itself.

=cut
