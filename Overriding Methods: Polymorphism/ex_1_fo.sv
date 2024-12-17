import uvm_pkg::*;

`include "uvm_macros.svh"

//--------------------xtn---------
class xtn extends uvm_sequence_item;
rand bit [3:0]addr;
rand bit [4:0]data;

//fucntion new constructor
function new(string name="xtn");
super.new(name);
endfunction 

`uvm_object_utils_begin(xtn)
 `uvm_field_int(addr,UVM_ALL_ON)
 `uvm_field_int(data,UVM_DEFAULT)
`uvm_object_utils_end
 
constraint valid_addr{addr==5; data==10;}
virtual function void display();
$display("I am in the BASE class");
endfunction 
endclass

//--------------small-xtn-------------
class small_xtn extends xtn;
 `uvm_object_utils(small_xtn)
rand bit [3:0]addr1;

function new(string name = "small_xtn");
super.new(name);
endfunction

constraint valid_addr{addr == 2;data == 4;}
constraint valid_ad1{addr1 == 10;}
virtual function void display();
$display("I am in Small_xtn Extended class");
$display("addr1 = %0d",addr1);
$display("%0d",this);
endfunction
endclass


//-------------big_xtn-------------
class big_xtn extends xtn;

`uvm_object_utils(big_xtn)

function new(string name="big_xtn");
super.new(name);
endfunction 

constraint valid_addr{addr==8;data==15;}

virtual function void display();
$display("I am in Big_xtn Extennded Class");
endfunction
endclass


//--------------small_xtn1------------
class small_xtn1 extends small_xtn;
`uvm_object_utils(small_xtn1)

function new(string name="small_xtn1");
super.new(name);
endfunction

constraint valid_addr{addr==1; data==2;}
endclass


module top();

xtn xt1;
function void build();
// xt1 = new("xt1");
xt1 = xtn::type_id::create("xt1");
// $display("Type is ",xt1.get_type());
// $display("Type Name is ",xt1.get_type_name());

repeat(2) 
begin
assert(xt1.randomize());
xt1.print();
xt1.display();
end
endfunction


initial begin
build();
xtn::type_id::set_type_override(small_xtn::get_type(),0);
factory.print();
build;
factory.set_type_override_by_name("xtn","small_xtn1",1);
factory.print();
build();
//factory.set_type_override_by_type(xtn::get_type(),small_xtn1::get_type(),0);
// factory.print();
// build();
factory.set_type_override_by_type(xtn::get_type(),big_xtn::get_type(),1);
factory.print();
build();
// factory.set_type_override_by_type(xtn::get_type(),small_xtn1::get_type(),1);
// factory.print();
// build();
end
endmodule




