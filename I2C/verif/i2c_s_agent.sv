class i2c_s_agent extends uvm_agent;
  
  `uvm_component_utils(i2c_s_agent)
  
  i2c_s_driver    s_driver_h;
  i2c_s_monitor   s_monitor_h;
  i2c_s_sequencer s_sqr_h;
  uvm_active_passive_enum is_active;
  
  function new(string name="i2c_s_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      s_driver_h  =i2c_s_driver::type_id::create("s_driver_h",this);
      s_monitor_h =i2c_s_monitor::type_id::create("s_monitor_h",this);
      s_sqr_h     =i2c_s_sequencer::type_id::create("s_sqr_h",this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
      s_driver_h.seq_item_port.connect(s_sqr_h.seq_item_export);
  endfunction : connect_phase
  
endclass : i2c_s_agent
