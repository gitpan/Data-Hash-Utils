#!/usr/bin/perl -Tw

use Test::More 'no_plan';
use Data::Util qw(sv_readonly_flag);

my @Exported_Funcs;
BEGIN { 
    @Exported_Funcs = qw(lock_keys   unlock_keys
                         lock_value  unlock_value
                         lock_hash   unlock_hash
                        );
    use_ok 'Hash::Util', @Exported_Funcs;
}
foreach my $func (@Exported_Funcs) {
    can_ok __PACKAGE__, $func;
}

my %hash = (foo => 42, bar => 23, locked => 'yep');
lock_keys(%hash);
eval { $hash{baz} = 99; };
like( $@, qr/^Attempt to access( to)? key 'baz' in fixed hash/,
                                                       'lock_keys()');
is( $hash{bar}, 23 );
ok( !exists $hash{baz} );

delete $hash{bar};
ok( !exists $hash{bar} );
$hash{bar} = 69;
is( $hash{bar}, 69 );


lock_value(%hash, 'locked');
eval { print "# oops" if $hash{four} };
like( $@, qr/^Attempt to access( to)? key 'four' in fixed hash/ );

eval { $hash{"\x{2323}"} = 3 };
like( $@, qr/^Attempt to access( to)? key '(.*)' in fixed hash/,
                                               'wide hex key' );

eval { delete $hash{locked} };
like( $@, qr/^Attempt to access( to)? key 'locked' in fixed hash/,
                                           'trying to delete a locked key' );
eval { $hash{locked} = 42; };
like( $@, qr/^Modification of a read-only value attempted/,
                                           'trying to change a locked key' );
is( $hash{locked}, 'yep' );

eval { delete $hash{I_dont_exist} };
like( $@, qr/^Attempt to access( to)? key 'I_dont_exist' in fixed hash/,
                             'trying to delete a key that doesnt exist' );

ok( !exists $hash{I_dont_exist} );

unlock_keys(%hash);
$hash{I_dont_exist} = 42;
is( $hash{I_dont_exist}, 42,    'unlock_keys' );

eval { $hash{locked} = 42; };
like( $@, qr/^Modification of a read-only value attempted/,
                             '  individual key still readonly' );
eval { delete $hash{locked} },
is( $@, '', '  but can be deleted :(' );

unlock_value(%hash, 'locked');
$hash{locked} = 42;
is( $hash{locked}, 42,  'unlock_value' );


TODO: {
#    local $TODO = 'assigning to a hash screws with locked keys';

    my %hash = ( foo => 42, locked => 23 );

    lock_keys(%hash);
    lock_value(%hash, 'locked');
    eval { %hash = ( wubble => 42 ) };  # we know this will bomb
    eval { unlock_value(%hash, 'locked') }; # but this shouldn't
    is( $@, '', 'unlock_value() after denied assignment' );

    is_deeply( \%hash, { foo => 42, locked => 23 },
                      'hash should not be altered by denied assignment' );
    unlock_keys(%hash);
}

TODO: { 
    # problem reported by JFriedl
#    local $TODO = 'should warn you about deleting RO';

    my %hash = (KEY => 'val', RO => 'val');
    lock_keys(%hash);
    lock_value(%hash, 'RO');

    eval { %hash = (KEY => 1) };
    like( $@, qr/^Attempt to access( to)? key 'RO' in fixed hash/ );
}

TODO: {
#    local $TODO = 'this should be allowed';

    my %hash = (KEY => 1, RO => 2);
    lock_keys(%hash);
    eval { %hash = (KEY => 1, RO => 2) };
    is( $@, '' );
}



{
    my %hash = ();
    lock_keys(%hash, qw(foo bar));
    is( keys %hash, 0,  'lock_keys() w/keyset shouldnt add new keys' );
    $hash{foo} = 42;
    is( keys %hash, 1 );
    eval { $hash{wibble} = 42 };
    like( $@, qr/^Attempt to access key 'wibble' in fixed hash/,
                        '  locked');

    unlock_keys(%hash);
    eval { $hash{wibble} = 23; };
    is( $@, '', 'unlock_keys' );
}


{
    my %hash = (foo => 42, bar => undef, baz => 0);
    lock_keys(%hash, qw(foo bar baz up down));
    is( keys %hash, 3,   'lock_keys() w/keyset didnt add new keys' );
    is_deeply( \%hash, { foo => 42, bar => undef, baz => 0 } );

    eval { $hash{up} = 42; };
    is( $@, '' );

    eval { $hash{wibble} = 23 };
    like( $@, qr/^Attempt to access key 'wibble' in fixed hash/, '  locked' );
}


{
    my %hash = (foo => 42, bar => undef);
    eval { lock_keys(%hash, qw(foo baz)); };
    is( $@, sprintf("Hash has key 'bar' which is not in the new key ".
                    "set at %s line %d\n", __FILE__, __LINE__ - 2) );
}


{
    my %hash = (foo => 42, bar => 23);
    lock_hash( %hash );

    ok( sv_readonly_flag(%hash) );
    ok( sv_readonly_flag($hash{foo}) );
    ok( sv_readonly_flag($hash{bar}) );

    unlock_hash ( %hash );

    ok( !sv_readonly_flag(%hash) );
    ok( !sv_readonly_flag($hash{foo}) );
    ok( !sv_readonly_flag($hash{bar}) );
}
