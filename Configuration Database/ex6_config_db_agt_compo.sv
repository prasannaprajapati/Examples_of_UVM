import uvm_pkg::*;
`include "uvm_macros.svh"

class my_config extends uvm_object;
`uvm_object_utils(my_config)

function new(string name="");
super.new(name);
endfunction

uvm_active_passive_enum is_active;
int no_of_agents;
endclass

class monitor extends uvm_monitor;
`uvm_component_utils(monitor)

function new(string name ="",uvm_component parent = null);
super.new(name,parent);
endfunction
endclass

class agent extends uvm_agent;
`uvm_component_utils(agent)

monitor mntr;
uvm_driver drv;
uvm_sequencer sqr;
my_config mcfg;

function new(string name ="",uvm_component parent = null);
super.new(name,parent);
// mcfg = my_config::type_id::create("mcfg");
// $display("mcfg = %0d",mcfg);
endfunction

virtual function void build_phase(uvm_phase phase);
if(!uvm_config_db #(my_config)::get(this,"","my_config",mcfg))
`uvm_fatal("TB CONFIG","Cannot get mcfg from uvm_config")
// $display(mcfg);
super.build_phase(phase);
mntr = monitor::type_id::create("mntr",this);
if(mcfg.is_active == UVM_ACTIVE) begin
drv = new("drv",this);
sqr = new("sqr",this);
end
endfunction
endclass

class agent_top extends uvm_env;
`uvm_component_utils(agent_top)

agent agnth[];
my_config mcfg;

function new(string name ="",uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db #(my_config)::get(this,"","my_config",mcfg))
`uvm_fatal(get_type_name(),"Getting failed. Check the Strings")
agnth = new[mcfg.no_of_agents];

foreach(agnth[i])
agnth[i] = agent::type_id::create($sformatf("agnth[%0d]",i),this);
endfunction
endclass

class env extends uvm_env;
`uvm_component_utils(env)

agent_top agth;

function new(string name ="",uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
agth = agent_top::type_id::create("agth",this);
endfunction
endclass

class test extends uvm_test;
`uvm_component_utils(test)

function new(string name ="",uvm_component parent = null);
super.new(name,parent);
endfunction

env envh;
my_config mcfg;

function void build_phase(uvm_phase phase);
super.build_phase(phase);
mcfg = my_config::type_id::create("mcfg");
// $display(mcfg);
mcfg.is_active = UVM_ACTIVE;
mcfg.no_of_agents = 3;
uvm_config_db #(my_config)::set(this,"*","my_config",mcfg);
envh = env::type_id::create("envh",this);
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
