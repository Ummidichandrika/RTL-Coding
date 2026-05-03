class i2c_m_sequencer extends uvm_sequencer#(i2c_seq_item);
  
  `uvm_component_utils(i2c_m_sequencer)
  
  function new(string name="i2c_m_sequencer",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  
endclass : i2c_m_sequencer 
