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

package output::Graphviz::Dot::Simple;

use strict;
use warnings;

use lib 'lib/';

sub new {
    my $class = shift;
    my $obj = {};
    bless ($obj, $class);

    # object variables
    $obj->{'dot_start'} = "digraph G {\n";
    $obj->{'dot_data'}  = '';
    $obj->{'dot_end'}   = "}\n";

    return ($obj);
}

sub append_node {
    my ($obj, $id, $parent, $node_name_full) = @_;

    #print "--> $id, $parent, $node_name_full\n";

    my $node_name = $node_name_full;
    if ($node_name_full =~ m/(.*)Department/ or $node_name_full =~ m/(.*)Division/) {
        $node_name = $1;
    }

    $obj->{'dot_data'} .= "\t$id [label=\"$node_name\",shape=box,fontsize=9];\n";
    $obj->{'dot_data'} .= "\t$parent -> $id;\n" unless ($parent eq 0);
}
 

sub get_raw_data {
    my ($obj) = @_;

    return $obj->{'dot_start'} . $obj->{'dot_data'} . $obj->{'dot_end'};
}

sub raw_to_file {
    my ($obj, $filename) = @_;

    open (my $F, ">$filename.dot");
    print $F $obj->get_raw_data();
    close ($F); 


    return "Data written to: $filename.dot\n";
}

sub graphic_to_file {
    my ($obj, $filename, $format) = @_;

    my $tmp_file = '/tmp/orgcreator.' . getpwuid($<) . '.tmpout';

    $obj->raw_to_file($tmp_file);

    `dot -T$format $tmp_file.dot -o $filename.$format`;

    unlink("$tmp_file.dot");

    return "Data written to: $filename.$format\n";

}

1;


__END__

=head1 NAME

output::Graphviz::Dot::Simple - Write a description of a tree diagram to stdout in the DOT-Format. Use it with the dot-program of Graphviz.

=head1 SYNOPSIS

 $formatter = output::Graphviz::Dot::Simple->new();
 
 $formatter->render($builder->get_tree());
 
 print $formatter->result();

=head1 DESCRIPTION

This module creates a text representation out of a hash-tree. The hash-tree must be from the module logic::Treebuilder.
The representation is done using the dot-format of graphviz.
Use the output to create a picture of the graph using dot of graphviz.

=head1 EXAMPLES

# see SYNOPSIS for now...

=head1 SEE ALSO

perldoc output::Graphviz::Dot::Simple

=head1 AUTHORS

Boris Däppen <boris_daeppen@bluewin.ch>

