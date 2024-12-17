import uvm_pkg::*;
`include "uvm_macros.svh"

class agent extends uvm_agent;
`uvm_component_utils(agent)
function new(string name ="agent",uvm_component parent = null);
super.new(name,parent);
endfunction
endclass

class agent_top extends uvm_env;
`uvm_component_utils(agent_top)
//declaring agent handle as dynamic array so that, we can increase/decrease no. of agent
agent agnth[];
int num;

function new(string name ="agent_top",uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
//if(!uvm_config_db #(int)::exists(this,"","int"))
//`uvm_fatal(get_type_name(),"Variable Does Not Exist")

if(!uvm_config_db#(int)::get(this,"","int",num))
`uvm_fatal(get_type_name(),"Getting failed. Check the Strings")
agnth = new[num]; //we are creating no. of agents depending upon the number passed in env
foreach(agnth[i])

agnth[i] = agent::type_id::create($sformatf("agnth[%0d]",i),this);
endfunction
endclass

class env extends uvm_env;
`uvm_component_utils(env)
agent_top agnth;

function new(string name ="env",uvm_component parent = null);
super.new(name,parent);
endfunction

int num;
function void build_phase(uvm_phase phase);
super.build_phase(phase);
/* num = 15; //we can modify no. of agent from here
uvm_config_db #(int)::set(this,"*","int",num); */
agnth = agent_top::type_id::create("agnth",this);
endfunction
endclass
 

class test extends uvm_test;
`uvm_component_utils(test)

function new(string name ="test",uvm_component parent = null);
super.new(name,parent);
endfunction

env envh;
int num;
int verbosity;

function void build_phase(uvm_phase phase);
super.build_phase(phase);
// we can set the num value from test as well as env
num = 19;
verbosity=UVM_LOW;
uvm_config_db #(int)::set(this,"*","int",num);
//uvm_config_db #(int)::set(this,"*","int",verbosity);
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