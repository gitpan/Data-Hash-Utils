#!/usr/bin/perl -Tw

use Test::More 'no_plan';

use Data::Util;
BEGIN { use_ok 'Data::Util', qw(sv_readonly_flag); }

ok( !sv_readonly_flag $foo );
ok( !sv_readonly_flag $foo, 1 );
ok( sv_readonly_flag $foo );
ok( sv_readonly_flag $foo, 0 );
ok( !sv_readonly_flag $foo );

ok( !sv_readonly_flag @foo );
ok( !sv_readonly_flag @foo, 1 );
ok( sv_readonly_flag @foo );
ok( sv_readonly_flag @foo, 0 );
ok( !sv_readonly_flag @foo );

ok( !sv_readonly_flag $foo[2] );
ok( !sv_readonly_flag $foo[2], 1 );
ok( sv_readonly_flag $foo[2] );
ok( sv_readonly_flag $foo[2], 0 );
ok( !sv_readonly_flag $foo[2] );

ok( !sv_readonly_flag %foo );
ok( !sv_readonly_flag %foo, 1 );
ok( sv_readonly_flag %foo );
ok( sv_readonly_flag %foo, 0 );
ok( !sv_readonly_flag %foo );

ok( !sv_readonly_flag $foo{foo} );
ok( !sv_readonly_flag $foo{foo}, 1 );
ok( sv_readonly_flag $foo{foo} );
ok( sv_readonly_flag $foo{foo}, 0 );
ok( !sv_readonly_flag $foo{foo} );
