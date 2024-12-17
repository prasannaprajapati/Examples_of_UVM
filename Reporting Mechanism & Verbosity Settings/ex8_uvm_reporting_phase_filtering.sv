import uvm_pkg::*;
`include "uvm_macros.svh"

class driver extends uvm_component;
`uvm_component_utils(driver)

function new(string name=get_type_name(),uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
`uvm_info(get_type_name(),"THIS IS BUILD PHASE OF DRIVER",UVM_LOW)
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
repeat(5) begin

phase.raise_objection(this,"Driving Started");
#10 `uvm_info(get_type_name(),"THIS IS RUN PHASE OF DRIVER",
UVM_LOW)
`uvm_error(get_type_name(),"ERROR IN RUN PHASE OF DRIVER")
phase.drop_objection(this,"Driving Ended");
end
endtask
endclass

class test extends uvm_component;
`uvm_component_utils(test)

driver drvh;
int default_fd;

function new(string name="test",uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
// `uvm_error(get_type_name(),"ERROR IN BUILD PHASE OF TEST")
`uvm_info(get_type_name(),"THIS IS BUILD PHASE OF TEST",UVM_LOW)
drvh = driver::type_id::create("drvh",this);
// default_fd = $fopen( "default_file.txt", "w" );
// drvh.set_report_default_file(default_fd );
// drvh.set_report_severity_action(UVM_INFO,UVM_LOG);
// drvh.set_report_verbosity_level(UVM_NONE);
// drvh.set_report_severity_action(UVM_INFO,UVM_NO_ACTION);
// drvh.set_report_id_action(drvh.get_type_name(),UVM_EXIT);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this,"Objection Raised in Test");
phase.get_objection().display_objections();
#5 `uvm_info(get_full_name(),"THIS IS RUN PHASE OF TEST",UVM_HIGH)
phase.drop_objection(this,"Objection Dropped in Test");
endtask
endclass

module top();
initial begin
// uvm_top.set_report_verbosity_level_hier(UVM_LOW);
run_test();
end
endmodule