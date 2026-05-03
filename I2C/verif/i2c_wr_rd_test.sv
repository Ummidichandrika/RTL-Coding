class i2c_wr_rd_test extends i2c_base_test;
  
  `uvm_component_utils(i2c_wr_rd_test)
 
  function new(string name="i2c_wr_rd_test",uvm_component parent=null);
	super.new(name,parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
  endfunction : build_phase
  
  task run_phase(uvm_phase phase);
	super.run_phase(phase);
	phase.raise_objection(this);
	`uvm_info("TEST","test after raise objection",UVM_LOW)
     wr_rd_seq_h.start(env_h.m_agent_h.m_sqr_h);
    `uvm_info("TEST","test before drop objection",UVM_LOW)
	phase.drop_objection(this);
  endtask : run_phase
  
endclass : i2c_wr_rd_test 
