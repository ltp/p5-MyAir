package MyAir::Zone;

use strict;
use warnings;

our @ATTR = qw(
	value
	measuredTemp
	state
	minDamper
	type
	rssi
	error
	setTemp
	name
	maxDamper
	motionConfig
	motion
	number
);

{
no strict 'refs';

for my $attr ( @ATTR ) {
	*{ __PACKAGE__ .":$attr" } = sub {
		my $self = shift;
		return $self->$attr
	}
}

sub new {
	my ( $class, $data ) = @_;

	my $self = bless {}, $class;

	$self->__init( $data );

	return $self
}

sub __init {
	my ( $self, $data ) = @_;

	$self->{ 
}

1;

__END__
