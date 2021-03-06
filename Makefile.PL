use strict;
use warnings;
use inc::Module::Install 0.91;
use Module::Install::AuthorRequires;
use Module::Install::AuthorTests;
use Module::Install::ReadmeFromPod;

all_from 'lib/Module/Install/AutoProvidesFromCompilation.pm';
readme_from 'lib/Module/Install/AutoProvidesFromCompilation.pm';

requires 'B::Compiling';
requires 'B::Hooks::Op::Check::StashChange';

author_requires 'Test::NoTabs';
author_requires 'Test::Pod' => '1.14';
author_requires 'Test::Pod::Coverage' => '1.04';

test_requires 'Test::More' => '0.88';
author_tests 't/author';
auto_install;

resources repository => 'git://github.com/bobtfish/Module-Install-AutoProvidesFromCompilation.git';

provides 'Module::Install::AutoProvidesFromCompilation' => 'lib/Module/Install/AutoProvidesFromCompilation.pm';

WriteAll;

