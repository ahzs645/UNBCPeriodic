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

/*[Text Configuration]*/
// Enable bottom text
enable_bottom_text = true;  // [true,false]
// Custom text line 1 (leave empty for auto-generated dovetail info)
custom_text_1 = "";  // Custom first line of text
// Custom text line 2 (leave empty for auto-generated size info)  
custom_text_2 = "";  // Custom second line of text
// Text size
text_size = 4;  // [2:0.5:8]
// Text depth (engraving depth)
text_depth = 1;  // [0.5:0.1:3]

/*[Component Selection]*/
// Which component to render
component = "single_box";  // [single_box,assembly_demo,periodic_table_layout,type1_inner,type2_top_edge,type3_right_edge,type4_bottom_edge,type5_left_edge,type6_corner_topleft,type7_corner_topright,type8_corner_bottomleft,type9_corner_bottomright,type10_lanthanide_left,type11_lanthanide_middle,type12_lanthanide_right,type13_gap_spacer]

/*[Demo Assembly]*/
// Number of boxes in X direction for demo
demo_boxes_x = 3;  // [1:1:5]
// Number of boxes in Y direction for demo  
demo_boxes_y = 3;  // [1:1:5]

/*[Periodic Table Layout]*/
// Show only main table (exclude lanthanides/actinides)
show_main_table_only = false;  // [true,false]
// Spacing between main table and lanthanide series
lanthanide_spacing = 20;  // [10:5:50]

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
} else if (component == "periodic_table_layout") {
    periodic_table_layout();
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
    north_open = undef,
    south_open = undef, 
    suppress_female = undef,
    suppress_male = undef,
    enable_card = undef,
    card_side = undef
) {
    // Use passed parameters or fall back to global settings
    actual_suppress_female = (suppress_female != undef) ? suppress_female : suppress_female_dt;
    actual_suppress_male = (suppress_male != undef) ? suppress_male : suppress_male_dt;
    actual_enable_card = (enable_card != undef) ? enable_card : enable_card_slot;
    actual_card_side = (card_side != undef) ? card_side : card_slot_side;
    
    difference() {
        union() {
            // Main box body with attached dovetails
            cuboid([box_length, box_width, box_height], anchor=BOTTOM) {
                // Add male dovetails if not suppressed
                if (!actual_suppress_male) {
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
                                        back_width = male_dt_back);
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
                                        back_width = male_dt_back);
                        }
                    }
                }
            }
        }
        
        // Subtract female dovetails if not suppressed
        if (!actual_suppress_female) {
            // Back side female dovetails (opposite of front male dovetails)
            if (box_length_units > 0) {
                for (i = [0:box_length_units-1]) {
                    translate([
                        (i + 0.5) * box_units - box_length/2,
                        box_width/2,
                        box_height/2
                    ])
                    rotate([90, 0, 180])
                        dovetail("female",
                                slide = box_height + eps,
                                width = female_dt_width,
                                height = female_dt_inside,
                                back_width = female_dt_back);
                }
            }
            
            // Right side female dovetails (opposite of left male dovetails)
            if (box_width_units > 0) {
                for (i = [0:box_width_units-1]) {
                    translate([
                        box_length/2,
                        (i + 0.5) * box_units - box_width/2,
                        box_height/2
                    ])
                    rotate([90, 0, 90])
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
        
        // Card slot
        if (actual_enable_card && actual_card_side != "none") {
            add_card_slot(actual_card_side);
        }
        
        // Bottom text
        if (enable_bottom_text) {
            add_info_text();
        }
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
    // Use custom text if provided, otherwise generate default text
    line1_text = (custom_text_1 != "") ? custom_text_1 : str("DT:", dt_width, "x", dt_inside_length);
    line2_text = (custom_text_2 != "") ? custom_text_2 : str(box_units, "x", box_height, "x", box_wall);
    
    translate([0, 0, text_depth]) {
        // First line of text
        linear_extrude(text_depth)
            text(line1_text, halign="center", valign="bottom", size=text_size);
        // Second line of text
        translate([0, -text_size * 1.5, 0])
            linear_extrude(text_depth)
                text(line2_text, halign="center", valign="top", size=text_size);
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
// ASSEMBLY DEMOS
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

// Periodic Table Layout - Simplified version showing proper box type placement
module periodic_table_layout() {
    // Main periodic table (18 columns x 7 rows)
    main_table_positions = [
        // Row 1: H and He (only corners)
        [0, 0, "type6_corner_topleft"],   // H
        [17, 0, "type7_corner_topright"], // He
        
        // Row 2: Li to Ne (8 elements)
        [0, 1, "type5_left_edge"],        // Li
        [1, 1, "type2_top_edge"],         // Be
        [12, 1, "type2_top_edge"],        // B
        [13, 1, "type2_top_edge"],        // C
        [14, 1, "type2_top_edge"],        // N
        [15, 1, "type2_top_edge"],        // O
        [16, 1, "type2_top_edge"],        // F
        [17, 1, "type3_right_edge"],      // Ne
        
        // Row 3: Na to Ar (8 elements)
        [0, 2, "type5_left_edge"],        // Na
        [1, 2, "type1_inner_box"],        // Mg
        [12, 2, "type1_inner_box"],       // Al
        [13, 2, "type1_inner_box"],       // Si
        [14, 2, "type1_inner_box"],       // P
        [15, 2, "type1_inner_box"],       // S
        [16, 2, "type1_inner_box"],       // Cl
        [17, 2, "type3_right_edge"],      // Ar
        
        // Row 4: K to Kr (18 elements)
        [0, 3, "type5_left_edge"],        // K
        [1, 3, "type1_inner_box"],        // Ca
        [2, 3, "type1_inner_box"],        // Sc
        [3, 3, "type1_inner_box"],        // Ti
        [4, 3, "type1_inner_box"],        // V
        [5, 3, "type1_inner_box"],        // Cr
        [6, 3, "type1_inner_box"],        // Mn
        [7, 3, "type1_inner_box"],        // Fe
        [8, 3, "type1_inner_box"],        // Co
        [9, 3, "type1_inner_box"],        // Ni
        [10, 3, "type1_inner_box"],       // Cu
        [11, 3, "type1_inner_box"],       // Zn
        [12, 3, "type1_inner_box"],       // Ga
        [13, 3, "type1_inner_box"],       // Ge
        [14, 3, "type1_inner_box"],       // As
        [15, 3, "type1_inner_box"],       // Se
        [16, 3, "type1_inner_box"],       // Br
        [17, 3, "type3_right_edge"],      // Kr
        
        // Row 5: Rb to Xe (18 elements)
        [0, 4, "type5_left_edge"],        // Rb
        [1, 4, "type1_inner_box"],        // Sr
        [2, 4, "type1_inner_box"],        // Y
        [3, 4, "type1_inner_box"],        // Zr
        [4, 4, "type1_inner_box"],        // Nb
        [5, 4, "type1_inner_box"],        // Mo
        [6, 4, "type1_inner_box"],        // Tc
        [7, 4, "type1_inner_box"],        // Ru
        [8, 4, "type1_inner_box"],        // Rh
        [9, 4, "type1_inner_box"],        // Pd
        [10, 4, "type1_inner_box"],       // Ag
        [11, 4, "type1_inner_box"],       // Cd
        [12, 4, "type1_inner_box"],       // In
        [13, 4, "type1_inner_box"],       // Sn
        [14, 4, "type1_inner_box"],       // Sb
        [15, 4, "type1_inner_box"],       // Te
        [16, 4, "type1_inner_box"],       // I
        [17, 4, "type3_right_edge"],      // Xe
        
        // Row 6: Cs to Rn (18 elements, includes La placeholder)
        [0, 5, "type5_left_edge"],        // Cs
        [1, 5, "type1_inner_box"],        // Ba
        [2, 5, "type1_inner_box"],        // La*
        [3, 5, "type1_inner_box"],        // Hf
        [4, 5, "type1_inner_box"],        // Ta
        [5, 5, "type1_inner_box"],        // W
        [6, 5, "type1_inner_box"],        // Re
        [7, 5, "type1_inner_box"],        // Os
        [8, 5, "type1_inner_box"],        // Ir
        [9, 5, "type1_inner_box"],        // Pt
        [10, 5, "type1_inner_box"],       // Au
        [11, 5, "type1_inner_box"],       // Hg
        [12, 5, "type1_inner_box"],       // Tl
        [13, 5, "type1_inner_box"],       // Pb
        [14, 5, "type1_inner_box"],       // Bi
        [15, 5, "type1_inner_box"],       // Po
        [16, 5, "type1_inner_box"],       // At
        [17, 5, "type3_right_edge"],      // Rn
        
        // Row 7: Fr to Og (18 elements, includes Ac placeholder)
        [0, 6, "type8_corner_bottomleft"], // Fr
        [1, 6, "type4_bottom_edge"],       // Ra
        [2, 6, "type4_bottom_edge"],       // Ac*
        [3, 6, "type4_bottom_edge"],       // Rf
        [4, 6, "type4_bottom_edge"],       // Db
        [5, 6, "type4_bottom_edge"],       // Sg
        [6, 6, "type4_bottom_edge"],       // Bh
        [7, 6, "type4_bottom_edge"],       // Hs
        [8, 6, "type4_bottom_edge"],       // Mt
        [9, 6, "type4_bottom_edge"],       // Ds
        [10, 6, "type4_bottom_edge"],      // Rg
        [11, 6, "type4_bottom_edge"],      // Cn
        [12, 6, "type4_bottom_edge"],      // Nh
        [13, 6, "type4_bottom_edge"],      // Fl
        [14, 6, "type4_bottom_edge"],      // Mc
        [15, 6, "type4_bottom_edge"],      // Lv
        [16, 6, "type4_bottom_edge"],      // Ts
        [17, 6, "type9_corner_bottomright"] // Og
    ];
    
    // Lanthanide series (Ce to Lu - 14 elements)
    lanthanide_positions = [
        [2, 8, "type10_lanthanide_left"],   // Ce (La already in main table)
        [3, 8, "type11_lanthanide_middle"], // Pr
        [4, 8, "type11_lanthanide_middle"], // Nd
        [5, 8, "type11_lanthanide_middle"], // Pm
        [6, 8, "type11_lanthanide_middle"], // Sm
        [7, 8, "type11_lanthanide_middle"], // Eu
        [8, 8, "type11_lanthanide_middle"], // Gd
        [9, 8, "type11_lanthanide_middle"], // Tb
        [10, 8, "type11_lanthanide_middle"], // Dy
        [11, 8, "type11_lanthanide_middle"], // Ho
        [12, 8, "type11_lanthanide_middle"], // Er
        [13, 8, "type11_lanthanide_middle"], // Tm
        [14, 8, "type11_lanthanide_middle"], // Yb
        [15, 8, "type12_lanthanide_right"]   // Lu
    ];
    
    // Actinide series (Th to Lr - 14 elements)
    actinide_positions = [
        [2, 9, "type10_lanthanide_left"],   // Th (Ac already in main table)
        [3, 9, "type11_lanthanide_middle"], // Pa
        [4, 9, "type11_lanthanide_middle"], // U
        [5, 9, "type11_lanthanide_middle"], // Np
        [6, 9, "type11_lanthanide_middle"], // Pu
        [7, 9, "type11_lanthanide_middle"], // Am
        [8, 9, "type11_lanthanide_middle"], // Cm
        [9, 9, "type11_lanthanide_middle"], // Bk
        [10, 9, "type11_lanthanide_middle"], // Cf
        [11, 9, "type11_lanthanide_middle"], // Es
        [12, 9, "type11_lanthanide_middle"], // Fm
        [13, 9, "type11_lanthanide_middle"], // Md
        [14, 9, "type11_lanthanide_middle"], // No
        [15, 9, "type12_lanthanide_right"]   // Lr
    ];
    
    // Render main table
    for (pos = main_table_positions) {
        x = pos[0];
        y = pos[1]; 
        box_type = pos[2];
        
        translate([x * box_length, y * box_width, 0]) {
            color("lightblue") render_box_type(box_type);
        }
    }
    
    // Render lanthanide/actinide series if not showing main table only
    if (!show_main_table_only) {
        translate([0, (7 + lanthanide_spacing/box_width) * box_width, 0]) {
            // Lanthanides
            for (pos = lanthanide_positions) {
                x = pos[0];
                y = pos[1] - 8; // Adjust for separation
                box_type = pos[2];
                
                translate([x * box_length, y * box_width, 0]) {
                    color("lightgreen") render_box_type(box_type);
                }
            }
            
            // Actinides
            for (pos = actinide_positions) {
                x = pos[0];
                y = pos[1] - 8; // Adjust for separation
                box_type = pos[2];
                
                translate([x * box_length, y * box_width, 0]) {
                    color("lightyellow") render_box_type(box_type);
                }
            }
        }
    }
}

// Helper module to render different box types
module render_box_type(box_type) {
    if (box_type == "type1_inner_box") type1_inner_box();
    else if (box_type == "type2_top_edge") type2_top_edge();
    else if (box_type == "type3_right_edge") type3_right_edge();
    else if (box_type == "type4_bottom_edge") type4_bottom_edge();
    else if (box_type == "type5_left_edge") type5_left_edge();
    else if (box_type == "type6_corner_topleft") type6_corner_topleft();
    else if (box_type == "type7_corner_topright") type7_corner_topright();
    else if (box_type == "type8_corner_bottomleft") type8_corner_bottomleft();
    else if (box_type == "type9_corner_bottomright") type9_corner_bottomright();
    else if (box_type == "type10_lanthanide_left") type10_lanthanide_left();
    else if (box_type == "type11_lanthanide_middle") type11_lanthanide_middle();
    else if (box_type == "type12_lanthanide_right") type12_lanthanide_right();
    else if (box_type == "type13_gap_spacer") type13_gap_spacer();
}

//==============================================================================
// PREDEFINED BOX TYPES - Call periodic_box with specific parameters
//==============================================================================

// Helper function to convert string booleans to actual booleans
function str_to_bool(str) = (str == "true") ? true : false;

// Type 1: Inner Box (most common)
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

// Type 2: Top Edge (no male dovetails on top)
module type2_top_edge() {
    periodic_box(
        suppress_female = false,
        suppress_male = false, // Keep male dovetails - they connect to boxes below
        enable_card = true,
        card_side = "south"
    );
}

// Type 3: Right Edge (no male dovetails on right)
module type3_right_edge() {
    periodic_box(
        suppress_female = false,
        suppress_male = true, // Remove male dovetails - nothing to connect to on right
        enable_card = true,
        card_side = "south"
    );
}

// Type 4: Bottom Edge (no female dovetails on bottom)
module type4_bottom_edge() {
    periodic_box(
        suppress_female = false,
        suppress_male = false, // Keep male dovetails for connecting to adjacent boxes
        enable_card = true,
        card_side = "south"
    );
}

// Type 5: Left Edge (no female dovetails on left)
module type5_left_edge() {
    periodic_box(
        suppress_female = true, // Remove female dovetails - nothing connects from left
        suppress_male = false,
        enable_card = true,
        card_side = "south"
    );
}

// Type 6: Corner Top-Left (Hydrogen)
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

// Type 7: Corner Top-Right (Helium)
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

// Type 8: Corner Bottom-Left (Francium)
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

// Type 9: Corner Bottom-Right (Oganesson)
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

// Type 10: Lanthanide Left End
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

// Type 11: Lanthanide Middle
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

// Type 12: Lanthanide Right End
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

// Type 13: Gap Spacer (no card slot)
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