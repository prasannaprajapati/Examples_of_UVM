import uvm_pkg::*;
`include "uvm_macros.svh"

class xtn extends uvm_sequence_item;

function new(string name = "xtn");
super.new(name);
endfunction

rand bit [3:0]addr;
rand bit [5:0]data;

`uvm_object_utils_begin(xtn)
`uvm_field_int(addr,UVM_ALL_ON)
`uvm_field_int(data,UVM_DEFAULT)
`uvm_object_utils_end
endclass

class my_seqr extends uvm_component;
uvm_put_port #(xtn)put_port;

`uvm_component_utils(my_seqr)

function new(string name = "my_seqr",uvm_component parent = null);
super.new(name,parent);
put_port = new("put_port",this);
endfunction

virtual task run_phase(uvm_phase phase);
xtn xtn1;
super.run_phase(phase);
repeat(2) begin
xtn1 = xtn::type_id::create("xtn1");
assert(xtn1.randomize());
`uvm_info(get_type_name(),"Packet Generated",UVM_LOW);
xtn1.print();
phase.raise_objection(this);
put_port.put(xtn1);
`uvm_info(get_type_name(),$sformatf("Can I put the packet in FIFO yes = %0d",put_port.can_put()),UVM_LOW)
phase.drop_objection(this);
end
endtask

virtual function void extract_phase(uvm_phase phase);
super.extract_phase(phase);
`uvm_info(get_type_name(),"Test Extract Phase",UVM_LOW)
endfunction
endclass

class my_drv1 extends uvm_component;
uvm_blocking_peek_port #(xtn)peek_port;

`uvm_component_utils(my_drv1)

function new(string name = "my_drv1",uvm_component parent = null);
super.new(name,parent);
peek_port = new("peek_port",this);
endfunction

task run_phase(uvm_phase phase);
xtn xtn3;
super.run_phase(phase);
phase.raise_objection(this);
repeat(2) begin
xtn3 = xtn::type_id::create("xtn3",this);
#5 peek_port.peek(xtn3);
`uvm_info(get_type_name(),"Packet Peeked",UVM_LOW);
xtn3.print();
end
phase.drop_objection(this);

endtask
endclass

class my_drv2 extends uvm_component;
uvm_get_port #(xtn)get_port;
`uvm_component_utils(my_drv2)
function new(string name = "my_drv2",uvm_component parent = null);
super.new(name,parent);
get_port = new("get_port",this);
endfunction

task run_phase(uvm_phase phase);
xtn xtn3;
super.run_phase(phase);
phase.raise_objection(this);
repeat(2) begin
xtn3 = xtn::type_id::create("xtn3",this);
#8 get_port.get(xtn3);
`uvm_info(get_type_name(),"Packet Received",UVM_LOW);
xtn3.print();
`uvm_info(get_type_name(),$sformatf("Can I get the packet yes = %0d",get_port.can_get()),UVM_LOW)
end
phase.drop_objection(this);
endtask
endclass

class my_test extends uvm_test;
`uvm_component_utils(my_test)

my_seqr seqr;
my_drv1 drvh1;
my_drv2 drvh2;

uvm_tlm_fifo #(xtn)fifo1;

function new(string name = "my_test",uvm_component parent = null);
super.new(name,parent);
seqr = my_seqr::type_id::create("seqr",this);
drvh1 = my_drv1::type_id::create("drvh1",this);
drvh2 = my_drv2::type_id::create("drvh2",this);
fifo1 = new("fifo1",this,2);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
seqr.put_port.connect(fifo1.put_export);
drvh1.peek_port.connect(fifo1.get_peek_export);
drvh2.get_port.connect(fifo1.get_export);
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