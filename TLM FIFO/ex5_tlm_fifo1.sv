//TLM FIFO
import uvm_pkg::*;
`include "uvm_macros.svh"

class A extends uvm_sequence_item;
// `uvm_object_utils(A);
function new(string name = "A");
super.new(name);
endfunction
rand bit [3:0]addr;
rand bit [5:0]data;
`uvm_object_utils_begin(A)
`uvm_field_int(addr,UVM_ALL_ON)
`uvm_field_int(data,UVM_DEFAULT)
`uvm_object_utils_end
endclass

class my_test extends uvm_test;
`uvm_component_utils(my_test)
uvm_blocking_put_port #(A)port;
uvm_blocking_get_port #(A)port1;
uvm_tlm_fifo #(A)fifo1;
A a,b;

function new(string name = "my_test",uvm_component parent = null);
super.new(name,parent);
port = new("port",this);
port1 = new("port1",this);
fifo1 = new("fifo1",this,10);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
port.connect(fifo1.put_export);
port1.connect(fifo1.get_export);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
`uvm_info(get_type_name(),$sformatf("FIFO Size = %0d",fifo1.size()),UVM_LOW)
repeat(2) begin
a = new("a");
assert(a.randomize());
a.print();
port.put(a);
`uvm_info(get_type_name(),"Data put into FIFO",UVM_LOW)
$display("Is fifo full = %0d",fifo1.is_full());
// fifo1.flush();
$display("fifo_used = %0d",fifo1.used());
$display("Is fifo empty = %0d",fifo1.is_empty());
port1.get(b);
b.print();
`uvm_info(get_type_name(),"Data get from FIFO",UVM_LOW)
end
endtask
endclass

module top();
initial
run_test("my_test");
endmodule