include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

/*[Box Dimensions]*/
// Box unit size in mm (target: 133mm for 5.25")
box_units = 40;  // [20:1:150]
// Box height in mm (target: 76mm for 3")  
box_height = 40;  // [20:1:100]
// Box wall thickness in mm (target: 4mm)
box_wall = 1.5;  // [1:0.1:5]
// Box floor thickness in mm
box_floor = 2;  // [1:0.1:5]

/*[Box Configuration]*/
// Box width in units (0 = minimal width)
box_width_units = 1;  // [0:1:5]
// Box length in units  
box_length_units = 1;  // [1:1:10]

/*[Dovetail Configuration]*/
// Dovetail tolerance for fit adjustment
dovetail_tolerance = 0.18;  // [0:0.01:0.5]
// Dovetail inside length in mm
dt_inside_length = 3;  // [1:0.1:5]
// Dovetail angle in degrees
dt_angle = 45;  // [30:5:60]
// Dovetail width in mm  
dt_width = 2;  // [1:0.1:4]

/*[Card Slot Configuration]*/
// Enable card slot for labels
enable_card_slot = true;  // [true,false]
// Width of card slot in mm
card_width = 30;  // [10:1:50]
// Height of card slot in mm
card_slot_height = 2;  // [1:0.1:5]
// Depth of card slot in mm
card_slot_depth = 15;  // [5:1:25]
// Card clearance tolerance in mm
card_clearance = 0.5;  // [0:0.1:2]
// Vertical position from bottom in mm
card_slot_y_pos = 10;  // [5:1:30]
// Card slot side placement
card_slot_side = "south";  // [none,south,north,both]

/*[Wall Configuration]*/
// North wall configuration
north_wall = "closed";  // [closed,open]
// South wall configuration  
south_wall = "closed";  // [closed,open]
// Enable rounded bottom
rounded_bottom = "none";  // [none,east_west,north_south]

/*[Dovetail Suppression]*/
// Suppress female dovetails
suppress_female_dt = false;  // [true,false]
// Suppress male dovetails
suppress_male_dt = false;  // [true,false]

/*[Component Selection]*/
// Which component to render
component = "single_box";  // [single_box,assembly_demo,type1_inner,type2_top_edge,type3_right_edge,type4_bottom_edge,type5_left_edge,type6_corner_topleft,type7_corner_topright,type8_corner_bottomleft,type9_corner_bottomright,type10_lanthanide_left,type11_lanthanide_middle,type12_lanthanide_right,type13_gap_spacer]

/*[Demo Assembly]*/
// Number of boxes in X direction for demo
demo_boxes_x = 3;  // [1:1:5]
// Number of boxes in Y direction for demo  
demo_boxes_y = 3;  // [1:1:5]

/*[Hidden - Derived Parameters]*/
// Calculate actual box dimensions
box_width = (box_width_units > 0) ? box_width_units * box_units : box_wall * 2;
box_length = box_length_units * box_units;

// Dovetail geometry calculations
dt_x = tan(dt_angle) * dt_width;
dt_back_width = dt_inside_length + 2 * dt_x;

// Adjusted dovetail dimensions for fit
male_dt_width = dt_width - dovetail_tolerance;
male_dt_inside = dt_inside_length - dovetail_tolerance;
male_dt_back = male_dt_inside + 2 * tan(dt_angle) * male_dt_width;

female_dt_width = dt_width + dovetail_tolerance;
female_dt_inside = dt_inside_length + dovetail_tolerance;
female_dt_back = female_dt_inside + 2 * tan(dt_angle) * female_dt_width;

// Small epsilon for CSG operations
eps = 0.01;

//==============================================================================
// MAIN RENDERING SWITCH
//==============================================================================

if (component == "single_box") {
    periodic_box();
} else if (component == "assembly_demo") {
    assembly_demo();
} else if (component == "type1_inner") {
    type1_inner_box();
} else if (component == "type2_top_edge") {
    type2_top_edge();
} else if (component == "type3_right_edge") {
    type3_right_edge();
} else if (component == "type4_bottom_edge") {
    type4_bottom_edge();
} else if (component == "type5_left_edge") {
    type5_left_edge();
} else if (component == "type6_corner_topleft") {
    type6_corner_topleft();
} else if (component == "type7_corner_topright") {
    type7_corner_topright();
} else if (component == "type8_corner_bottomleft") {
    type8_corner_bottomleft();
} else if (component == "type9_corner_bottomright") {
    type9_corner_bottomright();
} else if (component == "type10_lanthanide_left") {
    type10_lanthanide_left();
} else if (component == "type11_lanthanide_middle") {
    type11_lanthanide_middle();
} else if (component == "type12_lanthanide_right") {
    type12_lanthanide_right();
} else if (component == "type13_gap_spacer") {
    type13_gap_spacer();
}

//==============================================================================
// CORE BOX MODULE  
//==============================================================================

module periodic_box(
    north_open = false,
    south_open = false, 
    suppress_female = false,
    suppress_male = false,
    enable_card = true,
    card_side = "south"
) {
    difference() {
        union() {
            // Main box body with attached dovetails
            cuboid([box_length, box_width, box_height], anchor=BOTTOM) {
                // Add male dovetails if not suppressed
                if (!suppress_male) {
                    // North side male dovetails (along length)
                    if (box_length_units > 0) {
                        for (i = [0:box_length_units-1]) {
                            translate([
                                (i + 0.5) * box_units - box_length/2,
                                0,
                                0
                            ])
                            attach(FRONT)
                                dovetail("male",
                                        slide = box_height,
                                        width = male_dt_width,
                                        height = male_dt_inside, 
                                        back_width = male_dt_back,
                                        spin = 0);
                        }
                    }
                    
                    // West side male dovetails (along width)  
                    if (box_width_units > 0) {
                        for (i = [0:box_width_units-1]) {
                            translate([
                                0,
                                (i + 0.5) * box_units - box_width/2,
                                0
                            ])
                            attach(LEFT)
                                dovetail("male",
                                        slide = box_height,
                                        width = male_dt_width,
                                        height = male_dt_inside,
                                        back_width = male_dt_back,  
                                        spin = 90);
                        }
                    }
                }
            }
        }
        
        // Subtract female dovetails if not suppressed
        if (!suppress_female) {
            // South side female dovetails
            if (box_length_units > 0) {
                for (i = [0:box_length_units-1]) {
                    translate([
                        (i + 0.5) * box_units - box_length/2,
                        -box_width/2 - female_dt_inside/2,
                        box_height/2
                    ])
                    rotate([0, 90, 0])
                        dovetail("female",
                                slide = box_height + eps,
                                width = female_dt_width,
                                height = female_dt_inside,
                                back_width = female_dt_back);
                }
            }
            
            // East side female dovetails
            if (box_width_units > 0) {
                for (i = [0:box_width_units-1]) {
                    translate([
                        box_length/2 + female_dt_inside/2,
                        (i + 0.5) * box_units - box_width/2,
                        box_height/2
                    ])
                    rotate([0, 90, 90])
                        dovetail("female",
                                slide = box_height + eps,
                                width = female_dt_width,
                                height = female_dt_inside,
                                back_width = female_dt_back);
                }
            }
        }
        
        // Main cavity
        translate([0, 0, box_floor])
            cuboid([
                box_length - 2*box_wall - female_dt_width,
                box_width - 2*box_wall - female_dt_width, 
                box_height
            ], anchor=BOTTOM);
        
        // North wall opening
        if (north_open) {
            translate([0, box_width/2 - box_wall/2, box_floor])
                cuboid([
                    box_length - 2*box_wall - female_dt_width,
                    box_wall + eps,
                    box_height
                ], anchor=BOTTOM);
        }
        
        // South wall opening  
        if (south_open) {
            translate([0, -box_width/2 + box_wall/2, box_floor])
                cuboid([
                    box_length - 2*box_wall - female_dt_width,
                    box_wall + eps, 
                    box_height
                ], anchor=BOTTOM);
        }
        
        // Card slot
        if (enable_card && card_side != "none") {
            add_card_slot(card_side);
        }
        
        // Info text on bottom
        add_info_text();
    }
    
    // Add rounded bottom if enabled
    if (rounded_bottom != "none") {
        add_rounded_bottom();
    }
}

//==============================================================================
// HELPER MODULES
//==============================================================================

module add_card_slot(side) {
    slot_positions = [
        side == "south" ? [box_length/2, 0, card_slot_y_pos] : undef,
        side == "north" ? [-box_length/2, 0, card_slot_y_pos] : undef,
        side == "both" ? [[box_length/2, 0, card_slot_y_pos], [-box_length/2, 0, card_slot_y_pos]] : undef
    ];
    
    if (side == "south" || side == "north") {
        translate(side == "south" ? [box_length/2, 0, card_slot_y_pos] : [-box_length/2, 0, card_slot_y_pos]) {
            // External slot
            cuboid([box_wall + eps, card_width + card_clearance*2, card_slot_height], anchor=CENTER);
            // Internal channel
            translate([side == "south" ? -card_slot_depth/2 : card_slot_depth/2, 0, 0])
                cuboid([card_slot_depth, card_width + card_clearance*2, card_slot_height], anchor=CENTER);
        }
    } else if (side == "both") {
        add_card_slot("south");
        add_card_slot("north");
    }
}

module add_info_text() {
    dt_text = str("DT:", dt_width, "x", dt_inside_length);
    size_text = str(box_units, "x", box_height, "x", box_wall);
    
    translate([0, 0, 1]) {
        linear_extrude(1)
            text(dt_text, halign="center", valign="bottom", size=4);
        translate([0, -8, 0])
            linear_extrude(1)
                text(size_text, halign="center", valign="top", size=4);
    }
}

module add_rounded_bottom() {
    if (rounded_bottom == "east_west") {
        translate([0, 0, box_floor])
            rotate([0, 90, 0])
                linear_extrude(box_length - dt_width - box_wall, center=true)
                    difference() {
                        square([box_height/2, box_width - 2*box_wall], center=true);
                        translate([box_height/4, 0])
                            circle(d=box_width);
                    }
    }
    // Add north_south option similar to original if needed
}

//==============================================================================
// ASSEMBLY DEMO
//==============================================================================

module assembly_demo() {
    for (x = [0:demo_boxes_x-1]) {
        for (y = [0:demo_boxes_y-1]) {
            translate([x * box_length, y * box_width, 0]) {
                // Determine box type based on position
                is_corner = (x == 0 || x == demo_boxes_x-1) && (y == 0 || y == demo_boxes_y-1);
                is_edge = (x == 0 || x == demo_boxes_x-1 || y == 0 || y == demo_boxes_y-1) && !is_corner;
                
                if (is_corner) {
                    color("red") periodic_box(
                        north_open = (y == demo_boxes_y-1),
                        south_open = (y == 0),
                        suppress_female = (x == 0),
                        suppress_male = (x == demo_boxes_x-1)
                    );
                } else if (is_edge) {
                    color("orange") periodic_box(
                        north_open = (y == demo_boxes_y-1),
                        south_open = (y == 0),
                        suppress_female = (x == 0),
                        suppress_male = (x == demo_boxes_x-1)
                    );
                } else {
                    color("lightblue") periodic_box();
                }
            }
        }
    }
}

//==============================================================================
// PREDEFINED BOX TYPES
//==============================================================================

module type1_inner_box() {
    periodic_box(
        north_open = false,
        south_open = false,
        suppress_female = false, 
        suppress_male = false,
        enable_card = true,
        card_side = "south"
    );
}

module type2_top_edge() {
    periodic_box(
        north_open = true,
        south_open = false,
        suppress_female = false,
        suppress_male = false,
        enable_card = true, 
        card_side = "south"
    );
}

module type3_right_edge() {
    periodic_box(
        north_open = false,
        south_open = false,
        suppress_female = false,
        suppress_male = true,
        enable_card = true,
        card_side = "south"
    );
}

module type4_bottom_edge() {
    periodic_box(
        north_open = false,
        south_open = true,
        suppress_female = false,
        suppress_male = true,
        enable_card = true,
        card_side = "south"
    );
}

module type5_left_edge() {
    periodic_box(
        north_open = false,
        south_open = false,
        suppress_female = true,
        suppress_male = false,
        enable_card = true,
        card_side = "south"
    );
}

module type6_corner_topleft() {
    periodic_box(
        north_open = true,
        south_open = false,
        suppress_female = true,
        suppress_male = false,
        enable_card = true,
        card_side = "south"
    );
}

module type7_corner_topright() {
    periodic_box(
        north_open = true,
        south_open = false,
        suppress_female = false,
        suppress_male = true,
        enable_card = true,
        card_side = "south"
    );
}

module type8_corner_bottomleft() {
    periodic_box(
        north_open = false,
        south_open = true,
        suppress_female = true,
        suppress_male = false,
        enable_card = true,
        card_side = "south"
    );
}

module type9_corner_bottomright() {
    periodic_box(
        north_open = false,
        south_open = true,
        suppress_female = false,
        suppress_male = true,
        enable_card = true,
        card_side = "south"
    );
}

module type10_lanthanide_left() {
    periodic_box(
        north_open = false,
        south_open = true,
        suppress_female = true,
        suppress_male = false,
        enable_card = true,
        card_side = "south"
    );
}

module type11_lanthanide_middle() {
    periodic_box(
        north_open = false,
        south_open = true,
        suppress_female = false,
        suppress_male = false,
        enable_card = true,
        card_side = "south"
    );
}

module type12_lanthanide_right() {
    periodic_box(
        north_open = false,
        south_open = true,
        suppress_female = false,
        suppress_male = true,
        enable_card = true,
        card_side = "south"
    );
}

module type13_gap_spacer() {
    periodic_box(
        north_open = false,
        south_open = false,
        suppress_female = false,
        suppress_male = false,
        enable_card = false,
        card_side = "none"
    );
}