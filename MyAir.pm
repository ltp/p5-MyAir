package MyAir.pm

use strict;
use warnings;

use LWP;
use JSON;
use Time::HiRes;
use MyAir::Aircon;

our $VERSION= 0.01;

our $FAN_MAP = {
	low	=> 1,
	medium	=> 2,
	high	=> 3,
	auto	=> 4
};

our $MODE_MAP = {
	cool	=> 1,
	heat	=> 2,
	fan	=> 3,
	dry	=> 5
};

our $METHOD_MAP = {
	logoPIN		=> 'logoPIN',
	name		=> 'name',
	myAppRev	=> 'my_app_rev',
	hasLights	=> 'has_lights',
	dealerPhoneNumber=> 'dealer_phone_number',
	aaServiceRev	=> 'aa_service_rev',
	tspModel	=> 'tsp_model',
	sysType		=> 'sys_type',
	needsUpdate	=> 'needs_update',
	noOfSnapshots	=> 'no_of_snapshots',
	noOfAircons	=> 'no_of_aircons',
	rid		=> 'rid',
	mid		=> 'mid',
	hasAircons	=> 'has_aircons'
};

{
	no strict 'refs';

	for my $method ( keys %{ $METHOD_MAP } ) {
	*{ __PACKAGE__ ."::". $METHOD_MAP->{ $method } } = 
		sub {
			my $self = shift;
			return $self->{ __system }->{ $method }
		}
	}
}

sub new {
	my ( $class, %args ) = @_;

	my $self = bless {}, $class;

	$self->__init( %args );

	return $self
}

sub __init {
	my ( $self, %args ) = @_;

	$args{ host }
		? $self->{ host } = $args{ host }
		: die 'Host parameter not provided to constructor.' ;

	$self->{ port } = ( defined $args{ port } ? $args{ port }: 2025 );

	$self->{ aircon } = ( defined $args{ aircon } ? $args{ aircon } : 'ac1');

	$self->{ __ua } = LWP::UserAgent->new;
	$self->{ __jp } = JSON->new;

	$self->update or die 'Unable to retrieve initial system data.';

	# If we only have one aircon, set our aircon to that aircon id
	if ( $self->has_aircons eq 'true' and $self->no_of_aircons == 1 ) {
		$self->{ aircon } = ( keys %{ $self->__system->{ aircons } )[0]
	}
}

sub __ua {
	return $_[0]->{ __ua }
}

sub __jp {
	return $_[0]->{ __jp }
}

sub __system {
	return $_[0]->{ __system }
}

sub __aircon {
	return $_[0]->{ aircon }
}

sub update {
	my $self = shift;
	my $sleep = 0.01;

	for ( my $i = 0; $i < 30 ; $i++ ) {
		my $r = $self->__request( 'getSystemData' );

		if ( $r ) {
			$self->{ __system } = $r;

			return $self->{ system }
		}

		$sleep = $sleep *= 2 if $i < 5;

		Time::HiRes::sleep( $sleep )
	}

	warn( "Could not retrieve getSystemData" );

	return 0
}

sub zones {
	return $self->__system->{ aircons }->{ $self->__aircon }->{ zones }
}

sub zone {
	my ( $self, $zone ) = @_;

	$zone 	or warn( 'Zone not provided' )
		and return;

	defined $self->__system->{ aircons }->{ $self->__aircon }->{ zones }->{ $zone }
		or warn( "Zone $zone is not defined in system data" )
		and return;

	return $self->__system->{ aircons }->{ $self->__aircon }->{ zones }->{ $zone }
}


sub __request {
	my ( $self, $uri, $data ) = @_;

	my $r = HTTP::Request->new( GET => $uri );

	my $s = $self->__ua->request( $r );

	warn( "Request for $uri failed: $s->status_line\n" )
		if $s->is_error;

	return $sself->__jp->decode( $s->content )
}
	
1;

__END__

$m->mode
$m->mode( 'heat' )
$m->has_aircons
$m->ac( 'ac1' )->fan->low;
$m->ac( 'ac1' )->zones;
$m->ac( 'ac1' )->state;
$m->ac( 'ac1' )->state->on;
$m->ac( 'ac1' )->zone( 'Study' )->temp;
$m->ac( 'ac1' )->zone( 'Study' )->temp( 19 );





{"aircons":{"ac1":{"info":{"activationCodeStatus":"noCode","airconErrorCode":"","cbFWRevMajor":6,"cbFWRevMinor":20,"cbType":0,"constant1":1,"constant2":0,"constant3":0,"countDownToOff":0,"countDownToOn":0,"fan":"low","filterCleanStatus":0,"freshAirStatus":"none","mode":"cool","myZone":5,"name":"AC??","noOfConstants":1,"noOfZones":5,"rfSysID":5,"setTemp":21.0,"state":"off","uid":"0004a3029e91","unitType":17},"zones":{"z01":{"error":0,"maxDamper":100,"measuredTemp":24.1,"minDamper":0,"motion":0,"motionConfig":0,"name":"Living","number":1,"rssi":53,"setTemp":19.0,"state":"open","type":1,"value":100},"z02":{"error":0,"maxDamper":100,"measuredTemp":23.9,"minDamper":0,"motion":0,"motionConfig":0,"name":"Master bed","number":2,"rssi":38,"setTemp":20.0,"state":"close","type":1,"value":100},"z03":{"error":0,"maxDamper":100,"measuredTemp":23.4,"minDamper":0,"motion":0,"motionConfig":0,"name":"Bed 2","number":3,"rssi":33,"setTemp":20.0,"state":"close","type":1,"value":100},"z04":{"error":0,"maxDamper":100,"measuredTemp":24.0,"minDamper":0,"motion":0,"motionConfig":0,"name":"Bed 3","number":4,"rssi":56,"setTemp":20.0,"state":"close","type":1,"value":100},"z05":{"error":0,"maxDamper":100,"measuredTemp":24.5,"minDamper":0,"motion":0,"motionConfig":0,"name":"Study","number":5,"rssi":55,"setTemp":21.0,"state":"open","type":1,"value":100},"z06":{"name":"Zone6","number":6},"z07":{"name":"Zone7","number":7},"z08":{"name":"Zone8","number":8},"z09":{"name":"Zone9","number":9},"z10":{"name":"Zone10","number":10}}}},"myLights":{"alarms":{},"alarmsOrder":[],"groups":{},"groupsOrder":[],"lights":{},"scenes":{},"scenesOrder":[],"system":{"sunsetTime":""}},"snapshots":{},"system":{"aaServiceRev":"14.48","dealerPhoneNumber":"","hasAircons":true,"hasLights":false,"logoPIN":"1234","mid":"0004a3029e91","myAppRev":"15.220","name":"MyPlace","needsUpdate":false,"noOfAircons":1,"noOfSnapshots":0,"rid":"DLc0varcU4dC4PvZi2gOtcuRu7W2","sysType":"MyAir5","tspModel":"PIC8KS6-TSP7"}}
