class i2c_m_driver extends uvm_driver #(i2c_seq_item);
  
  `uvm_component_utils(i2c_m_driver) 
  
  virtual i2c_minterface mvif;
  i2c_env_config env_config_h;
  
  // Function New
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if ( !uvm_config_db#(virtual i2c_minterface) :: get( this, "", "mvif", mvif)) begin
      `uvm_fatal(get_type_name()," MASTER DRIVER : ERROR - Virtual Interface is not Set ")
    end
   
    if(!uvm_config_db #(i2c_env_config)::get(this,"","env_config_h",env_config_h)) begin
      `uvm_fatal(get_type_name()," MASTER DRIVER : ERROR - Environment Configuration is not Set ")
    end
  endfunction : build_phase   
   
  // Run Phase
  task run_phase(uvm_phase phase);  
     forever begin       
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name()," MASTER DRIVER : Initiating Start ",UVM_LOW)
       drive_start();    
      send_to_dut(req);
      seq_item_port.item_done();
     end
  endtask : run_phase
   
  
   task  drive_start();
   // @(posedge mvif.scl);
    #3;
     mvif.enable=req.enable;
    mvif.sda = 0;
    $display("Start");
    `uvm_info(get_type_name(),$sformatf(" MASTER DRIVER : Driving Start "), UVM_LOW)
    $display("done");
  endtask : drive_start  
  
  
  // Send To DUT
  task send_to_dut(input i2c_seq_item req);
        
    `uvm_info(get_type_name(),$sformatf(" MASTER DRIVER : Slave Address going to Send : %0h",req.slv_addr),UVM_LOW)
    
    mvif.rw = req.rw;
    mvif.data_in = req.data[0]; 
    mvif.addr = req.slv_addr;
    #150;
    drive_stop();
    $finish();
    
    if (req.rw == 0) begin
      `uvm_info(get_type_name(),$sformatf(" MASTER DRIVER : Write Data "), UVM_LOW)
    end
    
    if (req.rw == 1) begin
      `uvm_info(get_type_name(),$sformatf(" MASTER DRIVER : Read Data "), UVM_LOW)
    end
  endtask : send_to_dut  
          
 
 
        
  // Stop Condition
  task  drive_stop();
    `uvm_info(get_type_name()," MASTER DRIVER : Initiating Stop ",UVM_LOW)
    
    //@(posedge mvif.scl);
    #2us;
    mvif.enable=0;
    mvif.sda = 1'b1;
  endtask : drive_stop  
    
                  
endclass : i2c_m_driver                                          
                                            
