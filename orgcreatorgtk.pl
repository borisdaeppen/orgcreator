#!/usr/bin/perl

use strict;

use Gtk2 -init;
use Gtk2::GladeXML;

my $rendering_type = 'dot';

my $gui = Gtk2::GladeXML->new('lib/gui/orgcreatorgtk.glade');

$gui->signal_autoconnect_from_package();

Gtk2->main;

sub on_mainwindow_delete_event {
    Gtk2->main_quit;
}

sub on_quit1_activate {
    Gtk2->main_quit;
}

sub on_radiobutton_dot_clicked {
    $rendering_type = 'dot';
    print "changed to $rendering_type\n";
}
sub on_radiobutton_txt_clicked {
    $rendering_type = 'txt';
    print "changed to $rendering_type\n";
}
sub on_radiobutton_simple_clicked {
    $rendering_type = 'simple';
    print "changed to $rendering_type\n";
}

sub on_run_clicked {
    my $self = shift;

    my %opt = ();

    $opt{'platform'}    = $gui->get_widget('entry1')->get_text();
    $opt{'database'}    = $gui->get_widget('entry2')->get_text();
    $opt{'host'}        = $gui->get_widget('entry3')->get_text();
    $opt{'port'}        = $gui->get_widget('entry4')->get_text();
    $opt{'table'}       = $gui->get_widget('entry9')->get_text();
    $opt{'user'}        = $gui->get_widget('entry5')->get_text();
    $opt{'pw'}          = $gui->get_widget('entry6')->get_text();
    $opt{'file'}        = $gui->get_widget('entry8')->get_text().'/'.$gui->get_widget('entry7')->get_text();
    $opt{'module'}      = $rendering_type;
    print $gui->get_widget('radiobutton_dot')->get_group()."\n";

    my $argumentlist = '';

    while (my ($option, $value) = each %opt) {
        chomp ($value);

        if (length ($value) > 0) {
            $argumentlist .= "--$option $value ";
        }
    }

    my $command = "orgcreator.pl $argumentlist";

    my $output = `bash -c '$command' 2>&1`;

    $gui->get_widget('textview1')->get_buffer()->set_text("The following command was executed:\n\n$command\n\n\nThe output was as following:\n\n$output\n");


}


#use lib '.';
#
#use OrgcreatorGtk;
#
#OrgcreatorGtk->run;


