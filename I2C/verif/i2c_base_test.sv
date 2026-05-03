class i2c_base_test extends uvm_test;
  
  `uvm_component_utils(i2c_base_test)
  
  i2c_env env_h;
  i2c_wr_rd_seq      wr_rd_seq_h;
  i2c_env_config env_config_h;
  
  function new(string name="i2c_base_test",uvm_component parent=null);
	super.new(name,parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	env_h        =i2c_env::type_id::create("env_h",this);
    wr_rd_seq_h    = i2c_wr_rd_seq :: type_id :: create ("wr_rd_seq_h");
    env_config_h = i2c_env_config::type_id::create("env_config_h");
	uvm_config_db#(i2c_env_config)::set(null,"*","env_config_h",env_config_h);
  endfunction : build_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase
  
  task run_phase(uvm_phase phase);
	super.run_phase(phase);
	phase.raise_objection(this);
	`uvm_info("TEST","test after raise objection",UVM_LOW)
	phase.drop_objection(this);
    `uvm_info("TEST","test after raise objection --1",UVM_LOW)
  endtask : run_phase
  
endclass : i2c_base_test
