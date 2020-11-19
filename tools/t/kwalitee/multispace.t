use Test::Most;
use exact -conf;
use Cwd 'getcwd';
use Mojo::File 'path';
use Text::Gitignore 'build_gitignore_matcher';

my $root_dir = conf->get( qw( config_app root_dir ) );
my $cwd = getcwd();
chdir($root_dir);

my $matcher = build_gitignore_matcher( [
    '.git', map { s|^/|./|; $_ } split( "\n", path('.gitignore')->slurp )
] );

path('.')
    ->list_tree({ hidden => 1 })
    ->map( sub { './' . $_->to_rel } )
    ->grep( sub { -f $_ and -T $_ and not $matcher->($_) } )
    ->each( sub {
        ok( path($_)->slurp !~ /^[^\|\[]+\S[ ]{2,}/, "Multispace check on $_" );
    } );

chdir($cwd);
done_testing();
