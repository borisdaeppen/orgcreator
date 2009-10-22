#!/usr/bin/perl

use strict;
use warnings;

# perl modules
use DBI;
use DBD::mysql;

# path to private library
use lib 'lib';

# private modules
use output::Simpletext;
use output::Simplechart;
use logic::Treebuilder;
 
# Database variables
my $platform = "mysql";
my $database = "pcc_test";
my $host = "localhost";
my $port = "3306";
my $tablename = "hs_hr_compstructtree";
my $user = "hrm_root";
my $pw = "123.123";
my $dsn = "dbi:mysql:$database:localhost:3306";
 
# Database connection
my $connect = DBI->connect($dsn, $user, $pw);
my $query = "select id,parnt,title from $database.$tablename order by id";
my $query_handle = $connect->prepare($query);
$query_handle->execute();
 
# Database fetch results
my ($id, $parent, $label);
$query_handle->bind_columns(undef, \$id, \$parent, \$label);
 
my $builder = logic::Treebuilder->new();
while($query_handle->fetch()) {
    $builder->append($id, $parent, $label);
}


#use Data::Dumper;
#print Dumper($builder->get_tree());
my $formatter;
if($ARGV[0] eq 'txt') {
    $formatter = output::Simpletext->new();
}
else {
    $formatter = output::Simplechart->new();
}

$formatter->render($builder->get_tree());

print $formatter->result();


__END__

=head1 NAME

orgcreator.pl - Create an organigram of your companys structure out of OpenHRM.

=head1 SYNOPSIS

 perl orgcreator.pl     # creates a graphic
 perl orgcreator.pl txt # creates text

=head1 DESCRIPTION

This program is designed to use with OpenHRM. Create an organigram of your companys structure. Choose output format text ore graphic.

=head1 EXAMPLES

# see SYNOPSIS for now...

=head1 SEE ALSO

http://sourceforge.net/projects/orangehrm/

=head1 AUTHORS

Boris Däppen <boris_daeppen@bluewin.ch>
