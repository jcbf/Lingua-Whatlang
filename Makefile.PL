use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Lingua::Whatlang',
    AUTHOR           => 'jose.ferreira@anubisnetworks.com',
    VERSION_FROM     => 'lib/Lingua/Whatlang.pm',
    ABSTRACT_FROM    => 'lib/Lingua/Whatlang.pm',
    LICENSE          => 'artistic_2',
    MIN_PERL_VERSION => '5.010000',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    PREREQ_PM => {
        'FFI::Platypus' => '1.56', # Compatible with older infrastructure setups
    },
    clean => { FILES => 'target/ blib/' },
);

sub MY::postamble {
    return <<'MAKE_FRAG';
pure_all ::
	@echo "--- Compiling Rust FFI bridge via Cargo ---"
	cargo build --release
	@echo "--- Rust Compilation Finished ---"

clean ::
	@echo "--- Cleaning Rust artifacts ---"
	cargo clean
MAKE_FRAG
}

