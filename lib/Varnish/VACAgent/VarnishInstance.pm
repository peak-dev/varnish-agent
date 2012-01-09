package Varnish::VACAgent::VarnishInstance;

use Moose;

extends 'Reflex::Stream';

with 'Varnish::VACAgent::Role::Configurable';
with 'Varnish::VACAgent::Role::Logging';



has handle => (
    is => 'ro',
    isa => 'FileHandle',
    required => 1,
);

has agent => (
    is => 'ro',
    isa => 'Varnish::VACAgent::Singleton::Agent',
    lazy_build => 1,
);



sub _build_agent {
    return Varnish::VACAgent::Singleton::Agent->instance();
}



sub on_data {
    my ($self, $event) = @_;

    $self->info("VarnishInstance received data");

    my $response = $self->agent->handle_varnish_request($event->octets());
    $self->put($response);
}



sub on_error {
    my ($self, $event) = @_;
    warn(
        $event->error_function(),
        " error ", $event->error_number(),
        ": ", $event->error_string(),
    );
    $self->stopped();
}



sub DEMOLISH {
    $_[0]->debug("VarnishInstance demolished as it should.");
}



1;
