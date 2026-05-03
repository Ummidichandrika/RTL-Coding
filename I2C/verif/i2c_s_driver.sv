
class i2c_s_driver extends uvm_driver#(i2c_seq_item);
  
  `uvm_component_utils(i2c_s_driver) // Factory Registration
  
  virtual i2c_sinterface svif;        // Handle for Virtual Interface
  i2c_env_config env_config_h;       // Handle for Environment Configuration
  
    
  // Funtion New
  function new( string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new
    
  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      
    if(!uvm_config_db#(virtual i2c_sinterface)::get(this, "", "svif", svif)) begin
      `uvm_fatal(get_type_name()," SLAVE DRIVER : ERROR - Virtual Interface is not set ")
    end
      
      
    if(!uvm_config_db#(i2c_env_config)::get(this,"","env_config_h",env_config_h)) begin
      `uvm_fatal(get_type_name(), " SLAVE DRIVER : Slave Address Is not Set ")
    end
  endfunction : build_phase
  
  // Run Phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    check_start_condition();

    forever begin
      check_stop_condition();
      end  
   
  endtask : run_phase
   
  // Repeat Read Condition
/*  task repeat_read();
    `uvm_info(get_type_name()," SLAVE DRIVER : Reading Data from Slave ", UVM_LOW)
    slave_check_address();
    @(posedge svif.scl);
    rd_wrn = svif.sda;
    `uvm_info(get_type_name(),$sformatf(" SLAVE DRIVER : Received Read/Write Bit = %0b ",rd_wrn), UVM_LOW)
    send_ack();
    read_data();
  endtask : repeat_read*/
   
  // Start Condition
  task check_start_condition();
    forever begin
      @(negedge svif.sda);
      if (svif.scl == 1'b1) begin
        `uvm_info(get_type_name()," SLAVE DRIVER : Detected Start ",UVM_LOW)
        break;
      end
    end
      
  endtask : check_start_condition
    

  

  task check_stop_condition();
    fork
      begin
        @(posedge svif.scl);
        @(posedge svif.sda);
        `uvm_info(get_type_name()," SLAVE DRIVER : Stop Detected ",UVM_LOW)
      end
      begin
        @(posedge svif.scl);
        @(negedge svif.scl);
      end
      begin
        @(posedge svif.scl);
        @(negedge svif.sda);
        `uvm_info(get_type_name()," SLAVE DRIVER : Repeated Start Detected ",UVM_LOW)
      end
    join_any 
   disable fork;
  endtask : check_stop_condition
     
endclass : i2c_s_driver
