#!/usr/bin/perl

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
