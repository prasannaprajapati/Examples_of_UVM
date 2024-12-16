//ex1_flag.sv
//This example is the explaining about the deep copy 
//function which is having One Main Transcation which is Being
//copied to another main transcation class with subclass, but 
//when we updaing the subclass value of a in mh1.sb1 then it 
//will not change in mh2.sh1.a bcz it have separate subclass value 
//we can explicitly copy here

import uvm_pkg::*;
`include "uvm_macros.svh"

//Sub_transcation Class
class sub_trans extends uvm_sequence_item;
//`uvm_object_utils(sub_trans);
int a;
`uvm_object_utils_begin(sub_trans)
`uvm_field_int(a,UVM_DEFAULT)
`uvm_object_utils_end

function new(string name="");
super.new(name);
endfunction
endclass

//Main Transcation Class
class main_trans extends uvm_sequence_item;

sub_trans sb_th1 = new("sb_th1");

function new(string name = "");
super.new(name);
//`uvm_info(get_type_name(),$sformatf("%s",this.convert2string()),UVM_LOW)
endfunction
`uvm_object_utils_begin(main_trans)
`uvm_field_object(sb_th1,UVM_ALL_ON)
`uvm_object_utils_end

function string convert2string();
convert2string = {this.sprint()};
endfunction
endclass

module top();
main_trans mn_th1,mn_th2; // two handles for main-transcation class m1, m2;
initial 
     begin
		mn_th1 = main_trans::type_id::create("mn_th1"); // Create memmory for m1 
		$display("mn_th1 = %0d",mn_th1);
		$display("mn_th1.sb_th1 = %0d",mn_th1.sb_th1);
		
		mn_th1.sb_th1.a = 100;
		mn_th2 = main_trans::type_id::create("mn_th2");
		$display("mn_th2 = %0d",mn_th2);
		$display("mn_th2.sb_th1 = %0d",mn_th2.sb_th1);
		
		mn_th1.print();
		$display("Convert2string = %s",mn_th1.convert2string());
		
		mn_th2.copy(mn_th1); 
		$display("mn_th2 = %0d",mn_th2);
		$display("mn_th2.sb_th1 = %0d",mn_th2.sb_th1);
		
		mn_th2.print();
		mn_th2.sb_th1.a = 200;
		$display("a = %0d",mn_th2.sb_th1.a);
		$display("a in mn_th1 object = %0d",mn_th1.sb_th1.a);
mn_th2.print();
end
endmodule
