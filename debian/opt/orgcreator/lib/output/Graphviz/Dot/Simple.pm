#!/usr/bin/perl

package output::Graphviz::Dot::Simple;

use strict;
use warnings;

use lib 'lib/';

sub new {
    my $class = shift;
    my $obj = {};
    bless ($obj, $class);

    # object variables
    $obj->{'RETVAL'}        = '';
    $obj->{'img'}           = undef;
    $obj->{'img_width'}     = 8000;
    $obj->{'img_height'}    = 1200;
    $obj->{'offset'}        = 60;
    $obj->{'last_level'}    = -1;
    $obj->{'nesting'}       = 0;
    $obj->{'x_stack'}       = [];

    $obj->{'img_x_centre'}  = int ($obj->{'img_width'} / 2);
    $obj->{'img_y_centre'}  = int ($obj->{'img_height'} / 2);

    return ($obj);
}

sub render {
    my ($me, $tree) = @_;

    my $stack = [];

    # write a tree of boxes
    $me->{'RETVAL'} .= "digraph G {\n";
    $me->_doNode($tree, $stack);
    $me->{'RETVAL'} .= "}\n";

}

sub outfile {
    my $me = shift;
    $me->{'outfilename'} = shift;
}

sub _doNode {
    my ($me, $node, $stack) = @_;

    push (@{$stack}, $node);

    $me->_paintNode($node, $stack);

    my @children    = @{$node->{'VAR_children'}};

    foreach my $chield_node (@children) {
        $me->_doNode($chield_node, $stack);
        pop (@{$stack});
    }
}

sub _paintNode {
    my ($me, $node, $stack) = @_;
    #

    my $level       = (scalar @{$stack}) - 1;
    my $name        = $node->{'VAR_name'};
    my $weight      = $node->{'VAR_dependents'};
    my $parentid    = $node->{'VAR_parentid'};
    my $id          = $node->{'VAR_id'};
    my @children    = @{$node->{'VAR_children'}};

    my $parent = $stack->[$level - 1];
    my $parent_chield_numb = scalar @{$parent->{'VAR_children'}};
    my $total_number_of_nodes = $stack->[0]->{'VAR_dependents'} + 1;

    my $dependents_of_level = 0;

    my $shortname = $name;
    if ($name =~ m/(.*)Department/ or $name =~ m/(.*)Division/) {
        $shortname = $1;
    }

    $me->{'RETVAL'} .= "\t$id [label=\"$shortname\",shape=box,fontsize=9];\n";

    foreach my $chield (@children) {
        $me->{'RETVAL'} .= "\t$id -> $chield->{'VAR_id'};\n";
    }
}

sub result {
    my $obj = shift;

    open (my $MYFILE, ">$obj->{'outfilename'}.dot");
    print $MYFILE $obj->{'RETVAL'};
    close ($MYFILE); 

    `dot -Tpng $obj->{'outfilename'}.dot -o $obj->{'outfilename'}.png`;

    return "Data written to: $obj->{'outfilename'}.dot and $obj->{'outfilename'}.png\n";
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

