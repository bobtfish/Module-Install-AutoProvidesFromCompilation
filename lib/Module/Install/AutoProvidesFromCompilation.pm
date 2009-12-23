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
        ${$_.'::VERSION'} ? ( version => $_->VERSION() ) : ()
    }) for keys %packages;
}

1;

=head1 NAME

Module::Install::AutoProvidesFromCompilation

=head1 SYNOPSIS

    use inc::Module::Install;
    name 'Example';
    all_from 'lib/Example.pm'
    auto_provides_from_compilation();
    WriteAll;

=head1 DESCRIPTION

Ensures that your META.yml contains provides information for
every class in your lib/ directory.

=head1 AUTHOR

    Tomas Doran (t0m) <bobtfish@bobtfish.net>

=head1 COPYRIGHT

Copyright (C) 2009 Tomas Doran

=head1 LICENSE

This software is licensed under the same terms as perl itself.


