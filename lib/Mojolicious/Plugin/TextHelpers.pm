package Mojolicious::Plugin::TextHelpers;

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
	return $text unless $text and $n > 0;

	my $omited = @_ > 3 ? pop : '...';
	my @words  = split /\s+/, $text;
	$text = join ' ', @words[0..$n-1];

	if(@words > $n) {
	    $text =~ s/[[:punct:]]$//;
	    $text .= $omited;
	}

	return $text;
    });

    $app->helper(number => sub {
	my ($c, $number) = (shift, shift);
	my %options = @_;
	my $sep = $options{sep} // ',';
	my $dec = $options{decimal};

       (my $text = $number) =~ s/(\d)(?=(?:\d{3})+(?:\.\d+)?$)/$1$sep/g;
	$text =~ s/\.(\d+)$/$dec$1/ if defined $dec;

	return $text;
    });

    $app->helper(sanitize => sub {
	my $c    = shift;
	my $html = shift;
	return unless $html;

	my %options = @_;

	my (%tags, %attr);
	my $names = $options{tags};
	@tags{@$names} = (1) x @$names if ref $names eq 'ARRAY';

	$names= $options{attr};
	@attr{@$names} = (1) x @$names if ref $names eq 'ARRAY';

	my $doc = Mojo::DOM->new($html);
	return $doc->all_text unless %tags or %attr;

	for my $node (@{$doc->all_contents}) {
	    if(%tags && !$tags{ $node->type }) {
		$node->strip;
		next;
	    }

	    if(%attr) {
		for my $name (keys %{$node->attr}) {
		    delete $node->attr->{$name} unless $attr{$name};
		}
	    }
	}

	return $doc->to_string;
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
  $self->sanitize($html);       # remove all HTML
  $self->sanitize($html, tags => ['a','p']); # keep <p> and <a> tags

=head1 METHODS

=head2 count

    $self->count(10, 'user');           # 10 users
    $self->count([User->new]);          # 1 user
    $self->count([User->new], 'Luser'); # 1 Luser

=head2 maxwords

   $self->maxwords($str, $n);
   $self->maxwords($str, $n, '&hellip;');

Truncate C<$str> after C<$n> words. If C<$str> has more than C<$n> words traling
punctuation characters are stripped from the C<$n>th word and C<'...'> is appended.
An alternate ommision character can be given as the third option.

=head2 number

   $self->number(1500.55); # 1,500.55
   $self->number(1500.55, sep => '.', decimal => ','); # 1.500,55

Format a number.

=head2 paragraphs

    $self->paragraphs($text);

Wrap C<\r\n> delimited text in HTML paragraph tags (C<p>).

=head2 sanitize

    $self->sanitize($html);
    $self->sanitize($html, tags => ['a','p'], attr => ['href']);

Remove all HTML tags in the string given by C<$html>. If C<tags> and/or C<attr>
are given remove everything but those tags and attributes.

=head1 SEE ALSO

L<Mojolicious>, L<Lingua::EN::Inflect>, L<Number::Format>,

=cut
