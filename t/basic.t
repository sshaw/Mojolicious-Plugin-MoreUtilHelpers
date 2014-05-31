use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

package A::User;

sub new { bless {}, shift }

package main;

plugin 'TextHelpers';

get '/number' => sub {
  my $self = shift;
  $self->render(text => $self->number(123456));
};

get '/maxwords' => sub {
  my $self = shift;
  $self->render(text => $self->maxwords('a, b, c', 2));
};

get '/paragraphs' => sub {
  my $self = shift;
  $self->render(text => $self->paragraphs("Ass\r\nBass\r\nCass\r\n\r\n"));
};

get '/count' => sub {
  my $self = shift;
  #$self->render(text => $self->count([1,2,3],'users'));
  #$self->render(text => $self->count([A::User->new]));
  $self->render(text => $self->count([A::User->new, A::User->new]));
};

my $t = Test::Mojo->new;
$t->get_ok('/maxwords')->status_is(200)->content_is('Hello Mojo!');
$t->get_ok('/number')->status_is(200)->content_is('Hello Mojo!');
$t->get_ok('/paragraphs')->status_is(200)->content_is('Hello Mojo!');
$t->get_ok('/count')->status_is(200)->content_is('Hello Mojo!');

done_testing();
