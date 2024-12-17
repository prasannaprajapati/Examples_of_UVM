import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum {BAD,GOOD}var1;  //user defined datatype for changing the datatype

class my_xtn extends uvm_sequence_item;
rand bit [3:0]addr;
rand bit [7:0]data;
string strg;

constraint valid_addr{addr inside {[2:10]};}
constraint valid_data{data inside {[15:100]};}

`uvm_object_utils_begin(my_xtn)
`uvm_field_int(addr,UVM_ALL_ON)
`uvm_field_int(data,UVM_DEFAULT)
// `uvm_field_enum(var1,en_typ,UVM_DEFAULT)
`uvm_object_utils_end

function new(string name="my_xtn");
super.new(name);
endfunction

endclass

//top 
module top();
my_xtn xtn,xtn1,xtn2,xtn3;
//dynamic array
bit a[]; // supports 0 and 1, by default unsigned
int unsigned b[]; //int is by default signed, suppports 0,1, default bit is 32
byte unsigned c[]; //byte is by default signed, supports 0,1, default bit is 8
initial begin
xtn=my_xtn::type_id::create("xtn");
assert(xtn.randomize());

xtn.print();
$display("%s",xtn.sprint());
xtn.strg = $sformatf("%s",xtn.sprint());
$display("strg = %s",xtn.strg);

$cast(xtn1,xtn.clone());
xtn1.print();
$display("Comparison Results = %b",xtn.compare(xtn1));

xtn2 = my_xtn::type_id::create("xtn2");
xtn2.copy(xtn1);
xtn2.print();

xtn2.pack(a);
$display(a);
xtn2.pack_bytes(c);
$display(c);
xtn2.pack_ints(b);
$display(b);

xtn3 = my_xtn::type_id::create("xtn3");
xtn3.unpack(a);
xtn3.print();
xtn3.unpack_ints(b);
xtn3.print();
xtn3.unpack_bytes(c);
xtn3.print();
end
endmodule

