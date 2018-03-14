package MyAir::Aircon;

use strict;
use warnings;

use MyAir::Zone;

sub new {
	my ( $class, $data ) = @_;

	my $self = bless {}, $class;

	$self->__init( $data );

	return $self
}

sub __init {
	my ( $self, $data ) = @_;

	$self->{ info } = $data->{ info };

	map {
		$self->{ zones }->{ $_ } = MyAir::Zone->new( $data->{ zones }->{ $_ } )
	} keys %{ $data->{ zones } };
}

1;

__END__
