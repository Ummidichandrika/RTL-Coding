class i2c_seq_item extends uvm_sequence_item;
  
  bit [6:0]  slv_addr=7'b0101010;
  rand bit        rw;
  rand bit enable;
  rand bit [7:0]  data[$];
  rand bit        repeated_st;

  `uvm_object_utils_begin(i2c_seq_item)
  	`uvm_field_int(slv_addr, UVM_ALL_ON)
    `uvm_field_int(repeated_st, UVM_ALL_ON)
  	`uvm_field_int(rw    , UVM_ALL_ON)
  `uvm_field_int(enable    , UVM_ALL_ON)
  	`uvm_field_queue_int(data    , UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name="i2c_seq_item");
    super.new(name);
  endfunction : new
  
endclass : i2c_seq_item
    
  
