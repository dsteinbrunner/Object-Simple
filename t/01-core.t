use Test::More  'no_plan';
use strict;
use warnings;

use lib 't/01-core';

BEGIN{ use_ok( 'Object::Simple' ) }
can_ok( 'Object::Simple', qw( new ) ); 

use Book;
# new method
{
    my $book = Book->new;
    isa_ok( $book, 'Book', 'It is object' );
    isa_ok( $book, 'Object::Simple', 'Inherit Object::Simple' );
}

{
    my $book = Book->new( title => 'a' );
    
    is_deeply( 
        [ $book->title ], [ 'a' ],
        'setter and getter and constructor' 
    );
}

{
    my $book = Book->new( { title => 'a', author => 'b' } );
    
    is_deeply( 
        [ $book->title, $book->author ], [ 'a', 'b' ],
        'setter and getter and constructor' 
    );
}

{
    eval{
        my $book = Book->new( 'a' );
    };
    like( 
        $@, qr/key-value pairs must be passed to Book::new/,
        'not pass key value pair'
    );
}

{
    my $book = Book->new( noexist => 1 );
    is($book->{ noexist }, 1, 'no exist attr set value' );
}

{
    my $book = Book->new( title => undef );
    ok( exists $book->{ title } && !defined $book->{ title } , 'new undef pass' );
}

# setter return value
{
    my $book = Book->new;
    my $current_default = $book->author( 'p' );
    is( $current_default, 'p', 'return current value( default ) in case setter is called' );
}

{
    my $t = Book->new( price => 6 );
    my $c = $t->new;
    is($c->price, 1, 'call new from object');
    
}

# reference
{
    my $book = Book->new;
    my $ary = [ 1 ];
    $book->title( $ary );
    my $ary_get = $book->title;
    
    is( $ary, $ary_get, 'equel reference' );
    
    push @{ $ary }, 2;
    is_deeply( $ary_get, [ 1, 2 ], 'equal reference value' );
    
    # shallow copy
    my @ary_shallow = @{ $book->title };
    push @ary_shallow, 3;
    is_deeply( [@ary_shallow],[1, 2, 3 ], 'shallow copy' );
    is_deeply( $ary_get, [1,2 ], 'shallow copy not effective' );
    
    push @{ $book->title }, 3;
    is_deeply( $ary_get, [ 1, 2, 3 ], 'push array' );
    
}

use Point;
# direct hash access
{
    my $p = Point->new;
    $p->{ x } = 2;
    is( $p->x, 2, 'default overwrited' );
    
    $p->x( 3 );
    is( $p->{ x }, 3, 'direct access' );
    
    is( $p->y, 1, 'defalut normal' );
}
{
    my $p = Point->new;
    is_deeply($p, {x => 1, y => 1, p => $Object::Simple::META->{Point}{attr_options}{p}{default}->()}, 'default overwrited' );
    cmp_ok(ref $Object::Simple::META->{Point}{attr_options}{p}{default}, 'ne', $p->p, 'default different ref' );
}

use T1;
{
    my $t = T1->new( a => 1 );
    $t->a( undef );
    ok( !defined $t->a, 'undef value set' );
}

# read_only test
use T2;
{
    my $t = T2->new;
    is( $t->x, 1, 'read_only' );
    
    eval{ $t->x( 3 ) };
    like( $@, qr/T2::x is read only/, 'read_only die' );
}

use T3;
{
    my $t1 = T3->new;
    my $t2 = T3->new;
    isnt( $t1->x, $t2->x, 'default adress is diffrence' );
    is_deeply( $t1->x, $t2->x, 'default value is same' );
    
}

use T4;
{
    my $o = T4->new;
    is( $o->a1, 1, 'auto_build' );
    is( $o->a2, 1, 'auto_build direct access' );
    is( $o->_a4, 4, 'auto_build start under bar' );
    is( $o->__a5, 5, 'auto_build start double under bar' );
    
}

{
    my $o = T4->new;
    $o->a1(undef);
    ok(exists $o->{a1}, 'auto_build set undef key');
    ok(!defined $o->{a1}, 'auto_build set undef value');
    
    my $v = $o->a1;
    ok(exists $o->{a1}, 'auto_build set undef key');
    ok(!defined $o->{a1}, 'auto_build set undef value');
}


use T6;

{
    my $o = T6->new;
    is( $o->build_m1, 1, 'first build accessor' );
}

use T7;

{
    my $o = T7->new;
    is( $o->a1, 1, 'auto_build pass method ref' );
    is( $o->a2, 2, 'auto_build pass anonimous sub' );
}

use T10;
{
    my $t = T10->new;
    
    my $o = { a => 1 };
    $t->m1( $o );
    
    require Scalar::Util;
    
    ok( Scalar::Util::isweak($t->{m1}), 'weak ref' );
    #ok( Scalar::Util::isweak($t->m1), 'weak ref' );

    ok( !Scalar::Util::isweak( $t->{ m2 } ), 'not weak ref' );
    
    is_deeply($t->m1, {a => 1}, 'weak get');
    
    $o = undef;
    ok( !$t->m1, 'ref is removed' );
    
}

{
    use T13;
    my $t = T13->new;
    is_deeply($t, {title => 1, author => 3}, 'override');
    
}

eval "use T15";
like($@, qr/'A' is bad. attribute must be 'Attr'/, 'bat attribute name');

{
    use T16;
    my $t = T16->new;
    my $r = $t->m1('1');
    is($t->m1, '1', 'set');
    is($t, $r, 'chained');
    
    my $d = [3];
    $t->m2($d);
    is_deeply($t->m2, [3], 'weak and chained get value');
    
    my $d2 = [5];
    my $r2 = $t->m2($d2);
    is($r2, $t, 'weak and chained set value ret');
    is_deeply($t->m2, $d2, 'weak and chained set value');
    
}

{
    my $t = Book->new;
    is($t->price, 1, 'default value not setting' );
}
{
    my $t = Book->new(price => 100);
    is($t->price, 100, 'default value setting');
}
{
    my $t = Book->new(title => 1);
    is($t->title, 1, 'no default value');
}

{
    my $t = T3->new;
    is_deeply($t->x, [1], 'new default value reference');
}

{
    my $d = [1];
    my $t = T10->new(m1 => $d);
    is_deeply($t->m1, [1], 'new weak data');
    ok(Scalar::Util::isweak($t->{m1}), 'new weak');
}

{
    use T17;
    eval{T17->new};
    like($@, qr/Default has to be a code reference or constant value/, 'defalt error');
}

{
    my $d = Object::Simple::Functions::get_attrs_having_default('Book');
    is_deeply($d, ['price'], 'cached attrs having default');
}
{
    my $d = Object::Simple::Functions::get_weak_attrs('T10');
    is_deeply($d, ['m1'], 'cached weak attrs');
}
{
    eval "use T18";
    like($@, qr/T18::m1 'aaa' is invalid accessor option/);
}

{
    use T19;
    ok($T19::OK, 'unimport MODIFY_CODE_ATTRIBUTES');
}

__END__


