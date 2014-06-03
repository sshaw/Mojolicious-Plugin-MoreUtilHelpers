use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Mojolicious::Lite;

plugin 'TextHelpers';

get '/maxwords' => sub {
  my $self = shift;
  $self->render(text => $self->maxwords('a, b, c', 2));
};

get '/paragraphs' => sub {
  my $self = shift;
  $self->render(text => $self->paragraphs("Ass\r\nBass\r\nCass\r\n\r\n"));
};

my $t = Test::Mojo->new;
$t->get_ok('/maxwords')->status_is(200)->content_is('a, b...');
#$t->get_ok('/paragraphs')->status_is(200)->content_is('Hello Mojo!');

done_testing();
