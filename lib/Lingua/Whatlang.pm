package Lingua::Whatlang;

use strict;
use warnings;
use v5.10;
use FFI::Platypus 1.56;
use File::Spec;
use Cwd 'abs_path';

our $VERSION = '0.02';

# 1. Define the binary Record layout matching Rust's #[repr(C)] struct
package Lingua::Whatlang::Result {
    use FFI::Platypus::Record;
    record_layout_1(
        'string(4)'  => 'lang_code',
        'string(16)' => 'script_name',
        'double'     => 'confidence',
        'uint8'      => 'success',
    );
}

package Lingua::Whatlang;

my $ffi = FFI::Platypus->new( api => 1 );

my $lib_path = File::Spec->catfile('target', 'release', 'liblingua_whatlang_ffi.so');
if ( !-f $lib_path ) {
    $lib_path = abs_path(File::Spec->catfile('blib', 'arch', 'auto', 'Lingua', 'Whatlang', 'liblingua_whatlang_ffi.so'));
}

$ffi->lib($lib_path);

# Map the function using a record pointer wrapper
$ffi->attach( 'detect_language_ext' => ['string', 'record(Lingua::Whatlang::Result)*'] => 'void' );

sub detect {
    my ($class, $text) = @_;
    return unless defined $text && $text ne '';

    # Allocate the temporary struct inside Perl stack memory
    my $result = Lingua::Whatlang::Result->new;

    # Pass by reference to Rust
    detect_language_ext($text, $result);

    # Guard against failure states
    return unless $result->success;

    (my $lang = $result->lang_code) =~ s/\0.*\z//s;
    (my $script = $result->script_name) =~ s/\0.*\z//s;

    # Return a high-level key/value hash mapping
    return {
        lang       => $lang,
        script     => $script,
        confidence => $result->confidence,
    };
}

1;

__END__

=head1 NAME

Lingua::Whatlang - Blazingly fast natural language detection using Rust's whatlang crate

=head1 SYNOPSIS

    use Lingua::Whatlang;

    my $result = Lingua::Whatlang->detect("Olá, como vai?");
    # Returns: { lang => "por", script => "Latin", confidence => 1.0 }

=head1 DESCRIPTION

Lingua::Whatlang is an ultra-lightweight, high-throughput Perl interface
to the Rust 'whatlang' library. It uses minimal system memory and
identifies natural languages along with their written scripts via
efficient FFI bindings.

=head1 METHODS

=head2 detect( $text )

Accepts a scalar string input. Returns a hash reference containing:
C<lang> (ISO-639-3 string), C<script> (writing system), and C<confidence> score.
Returns C<undef> if detection completely fails.

=head1 AUTHOR

Your Name <you@cpan.org>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

