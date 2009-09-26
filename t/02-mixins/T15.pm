package T15;
use Object::Simple( base => 'B4', mixins => ['M18', 'M19']);

sub m1 {
    my $self = shift;
    return $self->Object::Simple::UPPER::m1(1);
}

sub m2 {
    my $self = shift;
    return $self->Object::Simple::UPPER::m2(1);
}

sub m3 {
    my $self = shift;
    return $self->Object::Simple::UPPER::m3(1);
}

sub m4 {
    my $self = shift;
    return $self->Object::Simple::UPPER::m4(1);
}

sub m5 : Attr {}

sub new {
    my $self = shift;
    return $self->Object::Simple::UPPER::new( m5 => 5);
}

sub m6 {
    my $self = shift;
    $self->Object::Simple::UPPER::m6;
}

sub m7 {
    my $self = shift;
    return $self->Object::Simple::call_mixin('M19', 'm7', 1, 2);
}

sub m8 {
    my $self = shift;
    return $self->Object::Simple::call_mixin('NoExist', 'm7');
}

sub m9 {
    my $self = shift;
    return $self->Object::Simple::call_mixin('M19', 'no_exist');
}

sub m10 {
    my $self = shift;
    return $self->Object::Simple::call_mixin;
}

sub m11 {
    my $self = shift;
    return $self->Object::Simple::call_mixin('M19');
}


sub M19 : Attr {}
sub M18 : Attr {}
sub B4  : Attr {}
sub B5  : Attr {}


Object::Simple->build_class;
