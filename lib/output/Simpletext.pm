#!/usr/bin/perl

package output::Simpletext;

use strict;
use warnings;

use GD::Simple;

use lib 'lib/';

use paint::Box;

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
    $me->_doNode($tree, $stack);

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

    for (0..($level)) {
        $me->{'RETVAL'} .= "\t";
    }
    $me->{'RETVAL'} .= $name;
    $me->{'RETVAL'} .= "\n";
}

sub result {
    my $obj = shift;

    open (my $MYFILE, ">$obj->{'outfilename'}.txt");
    print $MYFILE $obj->{'RETVAL'};
    close ($MYFILE);

    return "Data written to: $obj->{'outfilename'}.txt\n";
}


1;


__END__

=head1 NAME

output::Simpletext - Creat a simple text on standard output out of a hash-tree.

=head1 SYNOPSIS

 $formatter = output::Simpletext->new();
 
 $formatter->render($builder->get_tree());
 
 print $formatter->result();

=head1 DESCRIPTION

This module creates a some text representation out of a hash-tree. The hash-tree must be from the module logic::Treebuilder.
It uses the same interface as output::Simplechart.

=head1 EXAMPLES

# see SYNOPSIS for now...

=head1 SEE ALSO

perldoc logic::Treebuilder

=head1 AUTHORS

Boris Däppen <boris_daeppen@bluewin.ch>

