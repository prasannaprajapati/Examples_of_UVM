import uvm_pkg::*;
`include "uvm_macros.svh"

class xtn extends uvm_sequence_item;
//`uvm_object_utils(xtn)

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
uvm_blocking_put_port #(xtn)put_port1;
//uvm_blocking_put_port #(xtn)put_port2;
`uvm_component_utils(my_seqr)

function new(string name = "my_seqr",uvm_component parent= null);
super.new(name,parent);
put_port1 = new("put_port1",this);
//put_port2 = new("put_port2",this);
this.print();
endfunction

virtual task run_phase(uvm_phase phase);
xtn xtn1;
super.run_phase(phase);
repeat(2) begin
xtn1 = xtn::type_id::create("xtn1");
$display("xtn1 = %0d",xtn1);
assert(xtn1.randomize());
xtn1.print();
`uvm_info(get_type_name(),"Packet Generated",UVM_LOW);
phase.raise_objection(this);
#10 put_port1.put(xtn1);
//#10 put_port2.put(xtn1);
phase.drop_objection(this);
end
endtask

virtual function void extract_phase(uvm_phase phase);
super.extract_phase(phase);
`uvm_info(get_type_name(),"Test Extract Phase",UVM_LOW)
endfunction
endclass

class my_drv1 extends uvm_component;
uvm_blocking_put_imp #(xtn,my_drv1)put_imp;
`uvm_component_utils(my_drv1)

function new(string name = "my_drv",uvm_component parent = null);
super.new(name,parent);
put_imp = new("put_imp1",this);
endfunction

virtual task put(xtn xtn2);
xtn xtn3;
//$cast(xtn3,xtn2.clone());
xtn3 = new("xtn3");
xtn3.copy(xtn2);
xtn3.print();
`uvm_info(get_type_name(),"Packet Received at my_drv1",UVM_LOW);
endtask
endclass

class my_drv2 extends uvm_component;
uvm_blocking_put_imp #(xtn,my_drv2)put_imp;

`uvm_component_utils(my_drv2)

function new(string name = "my_drv2",uvm_component parent = null);
super.new(name,parent);
put_imp = new("put_imp",this);
endfunction

virtual task put(xtn xtn2);
xtn xtn3;
$cast(xtn3,xtn2.clone());
$display("xtn3 = %0d",xtn3);
xtn3.print();
`uvm_info(get_type_name(),"Packet Received at my_drv2",UVM_LOW);
endtask
endclass

class my_test extends uvm_test;
`uvm_component_utils(my_test)
my_seqr seqr;
my_drv1 drvh1;
//my_drv2 drvh2;
function new(string name = "my_test",uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
seqr = my_seqr::type_id::create("seqr",this);
drvh1 = my_drv1::type_id::create("drvh1",this);
//drvh2 = my_drv2::type_id::create("drvh2",this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
seqr.put_port1.connect(drvh1.put_imp);
// seqr.put_port2.connect(drvh2.put_imp);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
`uvm_info(seqr.get_type_name(),$sformatf("Sequencer Connected with %0d Driver(s)",seqr.put_port1.size()),UVM_LOW)
endfunction
endclass

module top();
initial
run_test();
endmodule