package Module::Install::ProvidesFromCompilation;
use base qw/Module::Install::Base/;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

sub auto_provides_from_compilation {
    my $self = shift;
    return unless $Module::Install::AUTHOR;
    require Module::Find;
    require B::Hooks::OP::Check::StashChange;
    require B::Compiling;
    require FindBin;
    require lib;
    my $dist_name = 'Example';
    my $libdir = "$FindBin::Bin/lib";
    lib->import($libdir);

    my %packages;

    our $id = B::Hooks::OP::Check::StashChange::register(sub {
        my ($new, $old) = @_;
        my $file = B::Compiling::PL_compiling()->file;
        return unless $file =~ s/^$libdir/lib/;
        $packages{$new} ||= $file
            if $new =~ /^$dist_name/;
    });

    require "$libdir/$dist_name";
    Module::Find::useall($dist_name);
    undef $id;

    no strict 'refs';
    provides($_ => {
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


