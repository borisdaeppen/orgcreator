#!/usr/bin/perl

# Copyright 2010 Boris Daeppen <boris_daeppen@bluewin.ch>
# 
# This file is part of orgcreator.
# 
# orgcreator is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# orgcreator is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with orgcreator.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

# perl modules
use DBI;
use DBD::mysql;
use Getopt::Long;

# path to project library
use lib '/opt/orgcreator/lib';

# project modules
use output::Graphviz::Dot::Simple;
 
# commandline options
my $platform    = "mysql";
my $database    = "orangehrm";
my $host        = "localhost";
my $port        = "3306";
my $tablename   = "hs_hr_compstructtree";
my $user        = "root";
my $pw          = "123";

my $format      = 'png';
my $file        = 'company_organigram';
my $verbose     = 0;
my $help        = 0;

# exit with error if no options where set
unless (scalar @ARGV) {
    print "\nERROR: no options set at all, this program will probably not work\nexiting...\n\n";
    exit 1;
}

# fetch the options to variables
my $args_ok = GetOptions   ('platform=s'    =>  \$platform,
                            'database=s'    =>  \$database,
                            'host=s'        =>  \$host,
                            'port=i'        =>  \$port,
                            'table=s'       =>  \$tablename,
                            'user=s'        =>  \$user,
                            'pw=s'          =>  \$pw,
                            'file=s'        =>  \$file,
                            'format=s'      =>  \$format,
                            'verbose'       =>  \$verbose,
                            'help'          =>  \$help,
                           );

# abort if getopt found any error
unless ($args_ok) {
    print "\nERROR in arguments!\nexiting...\n\n";
    exit 1;
}

# show help and exit if asked by user
if ($help) {
    print <<ARGS;
The following options are available:

    --platform    = [mysql]                  a DBI compatible word for db-driver
    --database    = [orangehrm]              the name of your database
    --host        = [localhost]              host of the database
    --port        = [3306]                   port of database
    --tablename   = [hs_hr_compstructtree]   table name with info of company structure
    --user        = [root]                   databse user
    --pw          = [123]                    database password
    --file        = [company_organigram]     file for the output
    --format      = [png,[jpg,svg,dotsrc]]   type of output
    --verbose                                enable messages
    --help                                   see this help and exit

ARGS
exit 0;
}

# print configuration if asked by user and proceed
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
    format       = $format 
    verbose      = $verbose      
    help         = $help      

ARGS
}

# database connection
my $dsn         = "dbi:$platform:$database:$host:$port";
my $connect = DBI->connect($dsn, $user, $pw);
unless ($connect) {
    print "orgcreator\tERROR: Database $dsn connection could not be established\n";
    exit 1;
}

# fire query
my $query = "select id,parnt,title from $database.$tablename order by id";
my $query_handle = $connect->prepare($query);
$query_handle->execute();
 
# database fetch results
my ($id, $parent, $label);
$query_handle->bind_columns(undef, \$id, \$parent, \$label);
 
my $dot = output::Graphviz::Dot::Simple->new();
while($query_handle->fetch()) {
    $dot->append_node($id, $parent, $label);
}

# create output according to requested format
if($format eq 'png') {
    print $dot->graphic_to_file($file, 'png');
}
elsif($format eq 'svg') {
    print $dot->graphic_to_file($file, 'svg');
}
elsif($format eq 'jpg') {
    print $dot->graphic_to_file($file, 'jpg');
}
elsif($format eq 'dotsrc') {
    print $dot->raw_to_file($file);
}


__END__

=head1 NAME

orgcreator.pl - Create an organigram of your companys structure out of OpenHRM.

=head1 SYNOPSIS

 perl orgcreator.pl --help    # see for instructions

=head1 DESCRIPTION

This program is designed for use with OpenHRM. Create an organigram of your companys structure.

=head1 EXAMPLES

# see SYNOPSIS for now...

=head1 SEE ALSO

http://sourceforge.net/projects/orangehrm/

=head1 AUTHORS

Boris Däppen <boris_daeppen@bluewin.ch>
