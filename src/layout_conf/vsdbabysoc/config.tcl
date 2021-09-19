set ::env(DESIGN_NAME) vsdbabysoc

#Sourcing
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/module/*.v]
set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/src/include]
set ::env(EXTRA_LIBS) [glob $::env(DESIGN_DIR)/src/*.lib]
set ::env(EXTRA_LEFS) [glob $::env(DESIGN_DIR)/src/*.lef]
set ::env(EXTRA_GDS_FILES) [glob $::env(DESIGN_DIR)/src/*.gds]
set ::env(BASE_SDC_FILE) [glob $::env(DESIGN_DIR)/src/*.sdc]

#Clock configuration
set ::env(CLOCK_PERIOD) "20.0"
# set ::env(CLOCK_PORT) ""
set ::env(CLOCK_PORT) "CLK"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

#Floorplanning Configuration
set ::env(FP_PIN_ORDER_CFG) [glob $::env(DESIGN_DIR)/pin_order.cfg]

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1500 1500"

set ::env(BOTTOM_MARGIN_MULT) 20
set ::env(TOP_MARGIN_MULT) 20
set ::env(LEFT_MARGIN_MULT) 100
set ::env(RIGHT_MARGIN_MULT) 100

#Placement Configuration
set ::env(MACRO_PLACEMENT_CFG) [glob $::env(DESIGN_DIR)/macro.cfg]

#Magic Configuration
set ::env(MAGIC_ZEROIZE_ORIGIN) 0
set ::env(MAGIC_EXT_USE_GDS) 1