use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Mojolicious::Lite;

plugin 'TextHelpers';

my @NUMBERS = (0, 1, 100, 1_000, 10_000, 100_000, 10_000_000);

my $process_numbers = sub {
    my $self = shift;
    my $options = ref($_[-1]) eq 'HASH' ? pop : {};
    my $fmt = join '|', ('%s') x @_;
    return sprintf $fmt, map { $self->number($_, %$options) } @_;
};

get '/number' => sub {
  my $self = shift;  
  $self->render(text => $self->$process_numbers(@NUMBERS));
};

get '/number_with_sep_option' => sub {
  my $self = shift;
  $self->render(text => $self->$process_numbers(@NUMBERS, {sep => '.'}));
};

get '/number_with_decimal' => sub {
  my $self = shift;
  my @decimals = map { $_ + 0.55 } @NUMBERS;
  $self->render(text => $self->$process_numbers(@decimals));
};

get '/number_with_decimal_option' => sub {
  my $self = shift;
  my @decimals = map { $_ + 0.55 } @NUMBERS;
  $self->render(text => $self->$process_numbers(@decimals, {decimal => ' '}));
};

my $t = Test::Mojo->new;
$t->get_ok('/number')->status_is(200)->content_is('0|1|100|1,000|10,000|100,000|10,000,000');
$t->get_ok('/number_with_sep_option')->status_is(200)->content_is('0|1|100|1.000|10.000|100.000|10.000.000');
$t->get_ok('/number_with_decimal')->status_is(200)->content_is('0.55|1.55|100.55|1,000.55|10,000.55|100,000.55|10,000,000.55');
$t->get_ok('/number_with_decimal_option')->status_is(200)->content_is('0 55|1 55|100 55|1,000 55|10,000 55|100,000 55|10,000,000 55');

done_testing();
