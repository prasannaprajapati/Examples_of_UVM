import uvm_pkg::*;
`include "uvm_macros.svh"

class xtn extends uvm_sequence_item;
// `uvm_object_utils(xtn)

function new(string name="xtn");
super.new(name);
endfunction

rand bit [3:0]addr;
rand bit [7:0]data;

`uvm_object_utils_begin(xtn)
`uvm_field_int(addr,UVM_ALL_ON)
`uvm_field_int(data,UVM_ALL_ON)
`uvm_object_utils_end
endclass

class my_seqr extends uvm_component;
uvm_analysis_port #(xtn)ap;

`uvm_component_utils(my_seqr)

function new(string name = "my_seqr",uvm_component parent = null);
super.new(name,parent);
ap = new("ap",this);
endfunction

virtual task run_phase(uvm_phase phase);
xtn xtn1;
super.run_phase(phase);
repeat(2) begin
xtn1 = xtn::type_id::create("xtn1");
assert(xtn1.randomize());
xtn1.print();
`uvm_info(get_type_name(),"Packet Generated",UVM_LOW);
phase.raise_objection(this);
#10;
ap.write(xtn1);
phase.drop_objection(this);
end
endtask

virtual function void extract_phase(uvm_phase phase);
super.extract_phase(phase);
`uvm_info(get_type_name(),"Test Extract Phase",UVM_LOW)
endfunction
endclass

class my_drv1 extends uvm_component;
uvm_tlm_analysis_fifo #(xtn)wr_fifo;

`uvm_component_utils(my_drv1)

function new(string name = "my_drv1",uvm_component parent = null);
super.new(name,parent);
wr_fifo = new("wr_fifo",this);
$display("Size of FIFO = %0d",wr_fifo.size());
endfunction

virtual task run_phase(uvm_phase phase);
xtn xtn3;
super.run_phase(phase);
forever begin
wr_fifo.get(xtn3);
xtn3.print();
`uvm_info(get_type_name(),"Packet Received",UVM_LOW);
end
endtask
endclass

class my_drv2 extends uvm_component;
uvm_analysis_imp #(xtn,my_drv2)wr1_imp;

`uvm_component_utils(my_drv2)

function new(string name = "my_drv2",uvm_component parent = null);
super.new(name,parent);
wr1_imp = new("wr1_imp",this);
endfunction

virtual function void write(xtn xtn2);
xtn xtn3;
$cast(xtn3,xtn2.clone());
xtn3.print();
`uvm_info(get_type_name(),"Packet Received",UVM_LOW);
endfunction
endclass

class my_test extends uvm_test;
`uvm_component_utils(my_test)

my_seqr seqr;
my_drv1 drvh1;
my_drv2 drvh2;

function new(string name = "my_test",uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
seqr = my_seqr::type_id::create("seqr",this);
drvh1 = my_drv1::type_id::create("drvh1",this);
drvh2 = my_drv2::type_id::create("drvh2",this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
seqr.ap.connect(drvh1.wr_fifo.analysis_export);
seqr.ap.connect(drvh2.wr1_imp);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction
endclass

module top();
initial
run_test("my_test");
endmodule