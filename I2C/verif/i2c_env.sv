class i2c_env extends uvm_env;
  
  `uvm_component_utils(i2c_env)
  
  i2c_m_agent m_agent_h;
  i2c_s_agent s_agent_h; 
  i2c_scoreboard sbd;
  
  function new(string name="i2c_env",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent_h=i2c_m_agent::type_id::create("m_agent_h",this);
    s_agent_h=i2c_s_agent::type_id::create("s_agent_h",this);
    sbd      =i2c_scoreboard::type_id::create("sbd",this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);            
    m_agent_h.m_monitor_h.monitor_analysis_port.connect(sbd.master_mon_export);
    s_agent_h.s_monitor_h.aport.connect(sbd.slave_mon_export);
  endfunction : connect_phase
  
endclass : i2c_env
