class i2c_m_agent extends uvm_agent;
  
  `uvm_component_utils(i2c_m_agent)
  
  i2c_m_driver    m_driver_h;
  i2c_m_monitor   m_monitor_h;
  i2c_m_sequencer m_sqr_h;
  uvm_active_passive_enum is_active;
  
  function new(string name="i2c_m_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_driver_h  =i2c_m_driver::type_id::create("m_driver_h",this);
    m_monitor_h =i2c_m_monitor::type_id::create("m_monitor_h",this);
    m_sqr_h     =i2c_m_sequencer::type_id::create("m_sqr_h",this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_driver_h.seq_item_port.connect(m_sqr_h.seq_item_export);
  endfunction : connect_phase
  
endclass : i2c_m_agent
