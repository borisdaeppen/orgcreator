#!/usr/bin/perl

package output::Simplechart;

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

    # the image to paint in
    $me->{'img'} = GD::Simple->new($me->{'img_width'}, $me->{'img_height'}); 
    #$me->{'img'}->fontsize(40);

    # draw a tree of boxes
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

#    print @{$stack};
#    print "\n";
    #print "DEBUG: lvl:$level\tid:$id\tparent:$parentid\tweigth:$weight\tchildren:".(scalar @children)."\tname:$name\n";
    my $box = paint::Box->new($me->{'img'});
    $box->setText($name);

    my $x = 0;
    my $y = 0;

    
    if ($level eq 0) {
        $x = 0;#$me->{'img_x_centre'};
        $node->{'VAR_x_zone_of_control'} = $me->{'img_width'};
    }
    elsif ($level > 0) {
        print "DEBUG: lvl:$level\tid:$id\tparent:$parentid\tweigth:$weight\tchildren:".(scalar @children)."\tname:$name\n";
        if (not exists $parent->{'VAR_paint_chield_drawn'}) {
            $parent->{'VAR_paint_chield_drawn'} = 0;
        }
        $dependents_of_level      = 1 if ($dependents_of_level eq 0);
        $node->{'VAR_dependents'} = 1 if ($node->{'VAR_dependents'} eq 0);

        $node->{'VAR_x_zone_of_control'}
            = int (($parent->{'VAR_x_zone_of_control'} / ($parent_chield_numb) ));
        $x = $parent->{'VAR_paint_x'}
            + int (($node->{'VAR_x_zone_of_control'} )
                * ($parent->{'VAR_paint_chield_drawn'} ));
        $parent->{'VAR_paint_chield_drawn'}++;
#        if (not exists $parent->{'VAR_paint_chield_drawn'}) {
#            $parent->{'VAR_paint_chield_drawn'} = 0;
#        }
#        foreach my $chield (@{$parent->{'VAR_children'}}) {
#            $dependents_of_level = $dependents_of_level + $chield->{'VAR_dependents'};
#        }
#        $dependents_of_level      = 1 if ($dependents_of_level eq 0);
#        $node->{'VAR_dependents'} = 1 if ($node->{'VAR_dependents'} eq 0);
#        $node->{'VAR_x_zone_of_control'}
#            = int (($parent->{'VAR_x_zone_of_control'} / ($dependents_of_level))
#                * ($node->{'VAR_dependents'}));
#        $x = $parent->{'VAR_paint_x'}
#            + int (($node->{'VAR_x_zone_of_control'} )
#                / ($parent_chield_numb ) * ($parent->{'VAR_paint_chield_drawn'} ));
#        $parent->{'VAR_paint_chield_drawn'}++;
    }
    $y = $level * 300;
    $node->{'VAR_paint_x'} = $x;
    $node->{'VAR_paint_y'} = $y;
    print "x:$x\ty:$y\tcontrol:$node->{'VAR_x_zone_of_control'}\tsistercount:$parent->{'VAR_paint_chield_drawn'}\tallsisters:$parent_chield_numb\tleveldependents:$dependents_of_level\tmydependents:$node->{'VAR_dependents'}\n";


    $box->setPosition($x,$y);
    $box->setSize(300/($level + 1) * 1.3);

    $box->draw();
   
}

sub result {
    my $obj = shift;

    return scalar $obj->PNGtoFile("$obj->{'outfilename'}.png");
}

# print to a file
sub PNGtoFile {
    my $me    = shift;
    my $fname = shift;
 
    open    (my $file, ">$fname.png") or die $!;
    binmode ($file);
    print    $file $me->{'img'}->png;
    close   ($file);
 
    return "file saved: $fname\n";
}

1;


__END__

=head1 NAME

output::Simplechart - Creat a simple chart out of a hash-tree.

=head1 SYNOPSIS

 $formatter = output::Simplechart->new();
 
 $formatter->render($builder->get_tree());
 
 print $formatter->result();

=head1 DESCRIPTION

This module creates a chart out of a hash-tree. The hash-tree must be from the module logic::Treebuilder.

=head1 EXAMPLES

# see SYNOPSIS for now...

=head1 SEE ALSO

perldoc logic::Treebuilder

=head1 AUTHORS

Boris Däppen <boris_daeppen@bluewin.ch>

