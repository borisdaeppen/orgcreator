#!/usr/bin/perl

use strict;
use warnings;

# perl modules
use DBI;
use DBD::mysql;
use Getopt::Long;

# path to private library
use lib 'lib';

# private modules
use output::Simpletext;
use output::Simplechart;
use output::Graphviz::Dot::Simple;
use logic::Treebuilder;
 
# commandline options
my $platform    = "mysql";
my $database    = "pcc_test";
my $host        = "localhost";
my $port        = "3306";
my $tablename   = "hs_hr_compstructtree";
my $user        = "hrm_root";
my $pw          = "123.123";

my $module      = 'dot';
my $file        = 'company_organigram';
my $verbose     = 0;
my $help        = 0;

my $args_ok = GetOptions   ('platform=s'    =>  \$platform,
                            'db=s'          =>  \$database,
                            'host=s'        =>  \$host,
                            'port=i'        =>  \$port,
                            'table=s'       =>  \$tablename,
                            'user=s'        =>  \$user,
                            'pw=s'          =>  \$pw,
                            'file=s'        =>  \$file,
                            'module=s'      =>  \$module,
                            'verbose'       =>  \$verbose,
                            'help'          =>  \$help,
                           );

unless ($args_ok) {
    print "\nERROR in arguments!\nexiting...\n\n";
    exit 1;
}

if ($help) {
    print <<ARGS;
The following options are available:

    platform    = [mysql]                  a DBI compatible word for db-driver
    database    = [orangehrm]              the name of your database
    host        = [localhost]              host of the database
    port        = [3306]                   port of database
    tablename   = [hs_hr_compstructtree]   table name with info of company structure
    user        = [root]                   databse user
    pw          = [123]                    database password
    file        = [company_organigram]     file for the output
    module      = [dot,[txt,simple]]       type of output
    verbose     =                          enable messages
    help        =                          see this help

ARGS
exit 0;
}

if ($verbose) {
    print <<ARGS;
Using the following settings:

    platform     = $platform     
    database     = $database     
    host         = $host         
    port         = $port         
    tablename    = $tablename    
    user         = $user         
    pw           = $pw           
    file         = $file 
    module       = $module 
    verbose      = $verbose      
    help         = $help      

ARGS
}

# Database connection
my $dsn         = "dbi:$platform:$database:$host:$port";
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
if($module eq 'txt') {
    $formatter = output::Simpletext->new();
}
elsif($module eq 'dot') {
    $formatter = output::Graphviz::Dot::Simple->new();
}
elsif($module eq 'simple') {
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
