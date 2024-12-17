import uvm_pkg::*;
`include "uvm_macros.svh"

class driver extends uvm_driver;
`uvm_component_utils(driver)

function new(string name="",uvm_component parent=null);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
`uvm_info(get_type_name(),"I am in Base Driver Class",UVM_LOW)
endtask
endclass

class driver_ex extends driver;
`uvm_component_utils(driver_ex)

function new(string name="",uvm_component parent=null);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
`uvm_info(get_type_name(),"I am in Extended Driver Class",UVM_LOW)
endtask
endclass

class agent1 extends uvm_agent;
`uvm_component_utils(agent1)

driver drv_h;

function new(string name="",uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
drv_h = driver::type_id::create("drv_h",this);
endfunction
endclass

class agent2 extends uvm_agent;
`uvm_component_utils(agent2)

driver drv_h;

function new(string name="",uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
drv_h = driver::type_id::create("drv_h",this);
$display("This is agent2 = %0d",this);
endfunction
endclass

class env extends uvm_env;
`uvm_component_utils(env)

agent1 agt_h1;
agent2 agt_h2;

function new(string name="",uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
agt_h1 = agent1::type_id::create("agt_h1",this);
agt_h2 = agent2::type_id::create("agt_h2",this);
$display("This is agent2 = %0d",agt_h2);
endfunction
endclass

class test extends uvm_test;
`uvm_component_utils(test)

env env_h;

function new(string name="",uvm_component parent=null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
env_h = env::type_id::create("env_h",this);
//driver::type_id::set_type_override(driver_ex::get_type());
//set_inst_override("*.agt_h1.*","driver","driver_ex");
set_inst_override_by_type("*",driver::get_type(),driver_ex::get_type());
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction
endclass

module top();
initial
run_test("test");
endmodule