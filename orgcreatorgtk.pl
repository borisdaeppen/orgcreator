#!/usr/bin/perl

use strict;
use warnings;
use Glib qw(TRUE FALSE);

use Gtk2 -init;

# Create main containers #
##########################
my $window = Gtk2::Window->new ('toplevel');
$window->signal_connect (delete_event => sub { Gtk2->main_quit });
my $main_box = Gtk2::VBox->new();
my $split_box = Gtk2::HBox->new();
my $input_frame = Gtk2::Frame->new('Input');
my $config_frame = Gtk2::Frame->new('Config');
my $output_frame = Gtk2::Frame->new('Output');
my $input_box = Gtk2::Table->new(2,10);
my $config_box = Gtk2::VBox->new(2,10);

# Create menu #
###############
my $menubar = Gtk2::MenuBar->new();
my $menu_file = Gtk2::Menu->new();
my $menuitem_file = Gtk2::MenuItem->new('File');
my $menuitem_help = Gtk2::MenuItem->new('Help');

my $menuitem_quit = Gtk2::MenuItem->new('Quit');
$menuitem_quit->signal_connect(activate => sub { Gtk2->main_quit });

$menu_file->add($menuitem_quit);

$menuitem_file->set_submenu($menu_file);

$menubar->add($menuitem_file);
$menubar->add($menuitem_help);

# Create Text-Area for Messages
my $output_scrolled_win = Gtk2::ScrolledWindow->new();
my $output_textview = Gtk2::TextView->new();
$output_scrolled_win->add($output_textview);

# Creating labels and text-entries     #
# to allow configuration of parameters #
########################################
my %inputlabel = ();
my %inputdata  = ();
# Create labels
$inputlabel{'platform'} = Gtk2::Label->new('Database Type');
$inputlabel{'database'} = Gtk2::Label->new('Database Name');
$inputlabel{'table'}    = Gtk2::Label->new('Database Tablename');
$inputlabel{'user'}     = Gtk2::Label->new('Database User');
$inputlabel{'pw'}       = Gtk2::Label->new('Database Password');
$inputlabel{'host'}     = Gtk2::Label->new('Hostname');
$inputlabel{'port'}     = Gtk2::Label->new('Port');
$inputlabel{'path'}     = Gtk2::Label->new('Output Path');
$inputlabel{'file'}     = Gtk2::Label->new('Output Filename');

# dynamicaly create text entries on base of labels
my $i = 0;
while (my ($name, $label) = each %inputlabel) {
    $label->set_alignment(0,0.5);
    $input_box->attach_defaults($label, 0, 1, $i, $i + 1);
    $inputdata{$name} = Gtk2::Entry->new();
    $input_box->attach_defaults($inputdata{$name}, 1, 2, $i ,$i + 1);
    $i++;
}

# Default values for entries in the input section
$inputdata{'platform'} ->set_text('mysql');
$inputdata{'database'} ->set_text('');
$inputdata{'table'}    ->set_text('hs_hr_compstructtree');
$inputdata{'user'}     ->set_text('');
$inputdata{'pw'}       ->set_text('');
$inputdata{'host'}     ->set_text('localhost');
$inputdata{'port'}     ->set_text('3306');
$inputdata{'path'}     ->set_text('~/Desktop');
$inputdata{'file'}     ->set_text('organigram');

# Create Radio-Button menu #
############################
my @radio_label = ('PNG', 'SVG', 'JPG', 'DOT source', 'plain text');
my $radio_group = undef;
my $radio_choice = "PNG"; # default value

# create radio button dynamicaly
foreach my $name (@radio_label) {
    my $radio_button = Gtk2::RadioButton->new($radio_group, $name);
    $radio_group = $radio_button->get_group();
    $radio_button->signal_connect( toggled => sub { if($radio_button->get_active()) { $radio_choice = $name; print "$name choosen\n";} });
    $config_box->add($radio_button);
}

# Start Button #
################
my $button_run = Gtk2::Button->new('run program');
$config_box->add($button_run);
$button_run->signal_connect(clicked => \&on_run_clicked);

# Put GUI together #
####################
$input_frame->add($input_box);
$config_frame->add($config_box);

$split_box->add($input_frame);
$split_box->add($config_frame);

$main_box->add($menubar);
$main_box->add($split_box);
$output_frame->add($output_scrolled_win);
$main_box->add($output_frame);
$main_box->add(Gtk2::Statusbar->new());
 
$window->add($main_box);
$window->show_all;

# run main loop #
#################
Gtk2->main;


###############
# SUBROUTINES #
###############
sub on_run_clicked {
    my $button = shift;
    my $argumentlist = '';

    while (my ($option, $entry) = each %inputdata) {
        next if ($option =~ /path/);
        my $value = $entry->get_text();
        chomp ($value);

        if (length ($value) > 0 ) {
            if($option =~ /file/) {
                my $path = $inputdata{'path'}->get_text();
                chomp($path);
                $argumentlist .= "--$option $path/$value ";
            }
            else {
                $argumentlist .= "--$option $value ";
            }
        }
    }
    my $command = "orgcreator $argumentlist";
    print "$command        --\n";

    my $output = `bash -c '$command' 2>&1`;

    $output_textview->get_buffer()->set_text("The following command was executed:\n\n$command\n\n\nThe output was as following:\n\n$output\n");

}
