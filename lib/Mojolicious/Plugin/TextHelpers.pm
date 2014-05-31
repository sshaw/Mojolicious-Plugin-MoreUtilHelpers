package Mojolicious::Plugin::TextHelpers
;
use Mojo::Base 'Mojolicious::Plugin';
use Lingua::EN::Inflect;

our $VERSION = '0.01';

sub register {
    my ($self, $app) = @_;

    $app->helper(count => sub {
        my ($c, $item, $type) = @_;
        my $count = $item;
        my $tr    = sub { lc( (split /::/, ref(shift))[-1] ) };

        if(ref($item) eq 'ARRAY') {
            $count = @$item;
            $type  = $tr->($item->[0]) unless $type;
        }

        $type ||= $tr->($item);
        return "$count " . Lingua::EN::Inflect::PL($type, $count);
    });

    $app->helper(paragraphs => sub {
        my ($c, $text) = @_;
        return unless $text;

        my $html = join '', map $c->tag('p', $_), split /^\s*\015\012/m, $text;
        return Mojo::ByteStream->new($html);
    });


    $app->helper(maxwords => sub {
        my ($c, $text, $n) = @_;
        return unless $text and $n > 0;

        my @words = split /\s+/, $text;
        $text = join ' ', @words[0..$n-1];
        if(@words > $n) {
            $text =~ s/[[:punct:]]$//;
            $text .= '&hellip;';
        }

        return Mojo::ByteStream->new($text);
    });

    $app->helper(number => sub { 
        my ($c, $number) = @_;
	my $sep  = ',';
       (my $text = $number) =~ s/(\d)(?=(?:\d{3})+(?:\.\d+)?$)/$1$sep/g;
	return $text;
    });
}

1;
__END__

=pod

=encoding utf8

=head1 NAME

Mojolicious::Plugin::TextHelpers - Methods to format, count, delimit, etc...

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('TextHelpers');

  # Mojolicious::Lite
  plugin 'TextHelpers';

  $self->count(10, 'user');     # 10 users
  $self->count([User->new]);    # 1 user
  $self->number('1500.55');     # 1,500.00
  $self->paragraphs($text);     # <p>line 1</p><p>line 2</p>...
  $self->maxwords('a, b, c', 2) # a, b... 

=head1 METHODS

=head2 count

    $self->count(10, 'user');           # 10 users
    $self->count([User->new])           # 1 user
    $self->count([User->new], 'Luser'); # 1 Luser

=head2 maxwords

   $self->maxwords($str, $n)

Truncate C<$str> after C<$n> words. If C<$str> has more than C<$n> words 
traling punctuation characters are stripped from the Nth world and C<'&hellip'> is appended.

=head2 number

   $self->number(1500.55)   # 1,500.55
   $self->number('1500.55') # same as above

Format a number.

=head2 paragraphs

    $self->paragraphs($text);

Wrap C<\r\n> delimited text in HTML paragraph tags (C<p>).

=head1 SEE ALSO

L<Mojolicious>, L<Lingua::EN::Inflect>, L<Number::Format>,

=cut
