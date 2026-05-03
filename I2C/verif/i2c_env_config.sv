class i2c_env_config extends uvm_object;
  
  `uvm_object_utils(i2c_env_config)
  
  bit [6:0] slv_addr = 7'b0101010;
  bit temp_flag;
  uvm_active_passive_enum is_active;
  
  function new(string name = "i2c_env_config");
    super.new(name);
  endfunction : new
  
endclass : i2c_env_config
