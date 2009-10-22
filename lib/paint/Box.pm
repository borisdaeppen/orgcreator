#!/usr/bin/perl

package paint::Box;

use strict;
use warnings;

use GD::Simple;

sub new {
    my $class = shift;
    my $image = shift;

    my $obj = {}; 
    bless ($obj, $class);

    # object-variable of a GD-image
    $obj->{'image'} = $image; 
    # default values for drawing the box
    $obj->{'txt'}           = 'a box!';
    $obj->{'size'}          = '100';
    $obj->{'x'}             = 5;
    $obj->{'y'}             = 5;
    $obj->{'x_offset'}      = 5;
    $obj->{'y_offset'}      = 5;

    return ($obj);
}

# draws the box in the image, given the settings it has
sub draw {
    my $obj = shift;

    # draw a rectangle
    $obj->{'image'}->bgcolor('yellow');
    $obj->{'image'}->fgcolor('black');
    $obj->{'image'}->rectangle($obj->{'x_offset'} + $obj->{'x'},
                               $obj->{'y_offset'} + $obj->{'y'},
                               $obj->{'x_offset'} + $obj->{'x'} + $obj->{'size'},
                               $obj->{'y_offset'} + $obj->{'y'} + int($obj->{'size'} * 0.75));

    # label the rectangle
    $obj->{'image'}->moveTo($obj->{'x_offset'} + $obj->{'x'}+5,
                            $obj->{'y_offset'} + $obj->{'y'}+15);
    my $lineheigth = 15;
    my @lines = split(/\s+/, $obj->{'txt'});
    foreach my $line (@lines) {
        $obj->{'image'}->string($line);
        $obj->{'image'}->moveTo($obj->{'x_offset'} + $obj->{'x'}+5,
                                $obj->{'y_offset'} + $obj->{'y'}+15+$lineheigth);
        $lineheigth = $lineheigth + 15;
    }

}

# set the rectangle label to some string
sub setText {
    my ($obj, $txt) = @_;

    $obj->{'txt'} = $txt;
}

# set the with of the box, heigth is half of it
sub setSize {
    my ($obj, $size) = @_;

    $obj->{'size'} = $size;

    if ($size < 50) {
        $obj->{'image'}->font(gdTinyFont);
    }
    elsif ($size < 100) {
        $obj->{'image'}->font(gdSmallFont);
    }
    elsif ($size < 150) {
        $obj->{'image'}->font(gdMediumBoldFont);
    }
    elsif ($size < 200) {
        $obj->{'image'}->font(gdLargeFont);
    }
    elsif ($size > 299) {
        $obj->{'image'}->font(gdGiantFont);
    }
}

# set the coordinates of the corner
sub setPosition {
    my ($obj, $x, $y) = @_;

    $obj->{'x'} = $x;
    $obj->{'y'} = $y;
}

sub setOffset {
    my ($obj, $x_offset, $y_offset) = @_;

    $obj->{'x_offset'} = $x_offset;
    $obj->{'y_offset'} = $y_offset;
}

1;


__END__

=head1 NAME

paint::Box - Draw a labeled and colored rectangular in image, using the GD library.

=head1 SYNOPSIS

 my $box = paint::Box->new($me->{'img'});

 $box->setText($name);
 $box->setPosition($x,$y);
 $box->setSize(300/($level + 1) * 1.3);

 $box->draw();

=head1 DESCRIPTION

Draw a labeled and colored rectangular in image, using the GD library.

=head1 EXAMPLES

# see SYNOPSIS for now...

=head1 SEE ALSO

perldoc GD::Simple

=head1 AUTHORS

Boris Däppen <boris_daeppen@bluewin.ch>

