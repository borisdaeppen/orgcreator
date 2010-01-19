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

package logic::Treebuilder;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $obj = {};
    bless ($obj, $class);

    $obj->{'tree_ref'} = {};

    return ($obj);
}

sub append {
    my ($me, $id, $parent, $label) = @_;
    my $tree = $me->{'tree_ref'};

    #print "DEBUG: treebuilder - $id, $parent, $label\n";

    # Root
    if ($parent == 0) {
    #print "DEBUG: root found - $id, $parent, $label\n";
        $me->{'tree_ref'} = {   'VAR_id'            => $id,
                                'VAR_parentid'      => -1,
                                'VAR_dependents'    => 0,
                                'VAR_children'      => [],
                                'VAR_name'          => $label
                            };
        $tree = $me->{'tree_ref'};
    }
    # second level
    elsif ($tree->{'VAR_id'} eq $parent) {
        push (@{$tree->{'VAR_children'}}, { 'VAR_id'            => $id,
                                            'VAR_parentid'      => $parent,
                                            'VAR_dependents'    => 0,
                                            'VAR_children'      => [],
                                            'VAR_name'          => $label
                                            });
        $tree->{'VAR_dependents'}++;
    }
    # third level
    else {
        for (my $i = 0; $i < scalar @{$tree->{'VAR_children'}}; $i++) {
            if ($tree->{'VAR_children'}->[$i]->{'VAR_id'} eq $parent) {
                push(@{$tree->{'VAR_children'}->[$i]->{'VAR_children'}},
                                          { 'VAR_id'            => $id,
                                            'VAR_parentid'      => $parent,
                                            'VAR_dependents'    => 0,
                                            'VAR_children'      => [],
                                            'VAR_name'          => $label
                                            });
                $tree->{'VAR_children'}->[$i]->{'VAR_dependents'}++;
                $tree->{'VAR_dependents'}++;
            }
    # fourth level
            else {
                for (my $k = 0; $k < scalar @{$tree->{'VAR_children'}}; $k++) {
                    for (my $j = 0; $j < scalar @{$tree->{'VAR_children'}->[$k]->{'VAR_children'}}; $j++) {
                        if ($tree->{'VAR_children'}->[$k]->{'VAR_children'}->[$j]->{'VAR_id'} eq $parent) {
                            unless (exists $me->{"passed_$id"}) {
                                push(@{$tree->{'VAR_children'}->[$k]->{'VAR_children'}->[$j]->{'VAR_children'}},
                                                          { 'VAR_id'            => $id,
                                                            'VAR_parentid'      => $parent,
                                                            'VAR_children'      => [],
                                                            'VAR_dependents'    => 0,
                                                            'VAR_name'          => $label
                                                            });
                                $tree->{'VAR_children'}->[$k]->{'VAR_children'}->[$j]->{'VAR_dependents'}++;
                                $tree->{'VAR_children'}->[$k]->{'VAR_dependents'}++;
                                $tree->{'VAR_dependents'}++;

                                $me->{"passed_$id"} = 1;
                            }
                            else {
                                # already inserted! do nothing...
                            }
                        }
                    }
                }
            }
        }
    }
}

sub get_tree {
    my ($me) = @_;
    return $me->{'tree_ref'};
}

1;

__END__

=head1 NAME

logic::Treebuilder - Build a hash-tree.

=head1 SYNOPSIS

 my $builder = logic::Treebuilder->new();
 
 while($query_handle->fetch()) {
         $builder->append($id, $parent, $label);
 }
 
 use Data::Dumper;
 print Dumper($builder->get_tree());

=head1 DESCRIPTION

Use the Treebuilder if you have data like this:

 id     parent      data
 1      0           mum
 2      1           me
 3      1           sista
 4      3           nephew

Given the SYNOPSIS above a tree like follows would appear:

       mum
        |
        |---------
        |        |
        me     sista
                 |
                 |
               nephew

The nodes do contain a lot of information about their position in the tree.
Use the Data::Dumper module as given in the SYNOPSIS to see what kind of data is provided.

=head1 EXAMPLES

# see SYNOPSIS for now...

=head1 SEE ALSO

perldoc Data::Dumper

=head1 AUTHORS

Boris Däppen <boris_daeppen@bluewin.ch>
