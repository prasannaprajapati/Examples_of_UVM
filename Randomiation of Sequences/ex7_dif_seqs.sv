import uvm_pkg::*;
`include "uvm_macros.svh"

class write_xtn extends uvm_sequence_item;
//`uvm_object_utils(write_xtn)

function new(string name="");
super.new(name);
endfunction

rand bit [3:0]addr;
rand bit [7:0]data;
rand bit wr_en;

`uvm_object_utils_begin(write_xtn)
`uvm_field_int(addr,UVM_DEFAULT)
`uvm_field_int(data,UVM_DEFAULT)
`uvm_field_int(wr_en,UVM_DEFAULT)
`uvm_object_utils_end
endclass

class write_seq_base extends uvm_sequence #(write_xtn);
`uvm_object_utils(write_seq_base)
function new(string name="write_seq_base");
super.new(name);
endfunction
endclass

class wseq_odd extends write_seq_base;
`uvm_object_utils(wseq_odd)

function new(string name="wseq_odd");
super.new(name);
endfunction

task body();
repeat(3) begin
req = write_xtn::type_id::create("req");
start_item(req);
if(req.randomize() with {data%2 == 1;})
finish_item(req);
end
endtask
endclass

class wseq_even extends write_seq_base;
`uvm_object_utils(wseq_even)

function new(string name="wseq_even");
super.new(name);
endfunction

task body();
m_sequencer.lock(this);
repeat(2) begin
req = write_xtn::type_id::create("req");
start_item(req);

assert(req.randomize() with {data%2 == 0;});

finish_item(req);
end
m_sequencer.unlock(this);
endtask
endclass

class wseq_random extends write_seq_base;
`uvm_object_utils(wseq_random)

function new(string name="wseq_random");
super.new(name);
endfunction

task body();
m_sequencer.grab(this);
repeat(1) begin
req = write_xtn::type_id::create("req");
start_item(req);

assert (req.randomize());
finish_item(req);
end

m_sequencer.ungrab(this);
endtask
endclass

class seqr extends uvm_sequencer #(write_xtn);
`uvm_component_utils(seqr)

function new(string name="seqr",uvm_component parent = null);
super.new(name,parent);
endfunction
endclass

class drvr extends uvm_driver #(write_xtn);
`uvm_component_utils(drvr)

function new(string name="drvr",uvm_component parent = null);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
seq_item_port.get_next_item(req);
#10 req.print();
seq_item_port.item_done();
end
endtask
endclass

class test extends uvm_test;
`uvm_component_utils(test)

function new(string name="test",uvm_component parent = null);
super.new(name,parent);
endfunction

seqr seqr_h;
drvr drvr_h;
wseq_odd wso_h;
wseq_even wse_h;
wseq_random wsr_h;

function void build_phase(uvm_phase phase);
super.build_phase(phase);
seqr_h = seqr::type_id::create("seqr_h",this);
drvr_h = drvr::type_id::create("drvr_h",this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
drvr_h.seq_item_port.connect(seqr_h.seq_item_export);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction

function void start_of_simulation_phase(uvm_phase phase);
super.start_of_simulation_phase(phase);
// seqr_h.set_arbitration(SEQ_ARB_STRICT_FIFO);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
//seq1 of write odd seq
wso_h = wseq_odd::type_id::create("wso_h");
//seq2 of write even seq
wse_h = wseq_even::type_id::create("wse_h");
//seq3 of write random seq
wsr_h = wseq_random::type_id::create("wsr_h");
// `uvm_info(get_type_name(),$sformatf("wso_h = %0d",wso_h),UVM_LOW)
// `uvm_info(get_type_name(),$sformatf("wso_h = %0d",wse_h),UVM_LOW)
// `uvm_info(get_type_name(),$sformatf("wso_h = %0d",wsr_h),UVM_LOW)
phase.raise_objection(this);
fork
wso_h.start(seqr_h,,200);
wse_h.start(seqr_h,,300);
wsr_h.start(seqr_h,,400);
join
phase.drop_objection(this);
endtask

task main_phase(uvm_phase phase);
phase.raise_objection(this);
#1;
`uvm_info(get_type_name(),$sformatf("is_grabbed = %0d",seqr_h.is_grabbed()),UVM_LOW);
$display("Current grabber is %0d",seqr_h.current_grabber);
uvm_top.print_topology();
phase.drop_objection(this);
endtask
endclass

module top();
initial
run_test();
endmodule