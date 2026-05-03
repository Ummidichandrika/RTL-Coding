
class i2c_m_monitor extends uvm_monitor;
  
  `uvm_component_utils(i2c_m_monitor)                                           //FACTORY REGISTRATION

  virtual i2c_minterface mvif;
  i2c_seq_item item;
  i2c_env_config env_config_h;
  
  bit        ack          = 0;
  bit        start        = 0;
  bit        stopcheck    = 0;
  bit        flag         = 0;
  bit        repeat_start = 0;
  bit [6:0]  slave_addr_temp;
  bit [7:0]  temp_data;  
      
  uvm_analysis_port #(i2c_seq_item) monitor_analysis_port ;                   //ANALYSIS PORT DECLARATION
  
  function new(string name="i2c_m_monitor", uvm_component parent);            //CONSTRUCTOR
    super.new(name,parent);	
    monitor_analysis_port = new("monitor_analysis_port",this);		
  endfunction : new
	 
  function void build_phase(uvm_phase phase);                               //BUILD PHASE                    
	super.build_phase(phase);
    if(!uvm_config_db#(virtual interface i2c_minterface)::get(this," ","mvif",mvif)) begin   //GETTING INTERFACE IN MONITOR
      `uvm_fatal("i2c_m_monitor","MstrMon cannot get the i2c_interface")
    end
            
    if(!uvm_config_db #(i2c_env_config)::get(this,"","env_config_h",env_config_h)) begin   //GETTING ENV CONFIG CLASS IN MONITOR
      `uvm_fatal("i2c_m_monitor","MstrMon cannot get the env config")     
    end
  endfunction : build_phase
	
  task run_phase(uvm_phase phase);                                         //RUN PHASE
    forever begin
      item = i2c_seq_item::type_id::create("item");                       //CREATING HANDLE FOR SEQ_ITEM CLASS
      monitor_start();                                                    //START CONDITION
      start = 0; 
      `uvm_info(get_type_name(),"MstrMon received start condition",UVM_LOW) 
      collect_data(item);                                                //TASK COLLECT DATA-WRITE OR READ 
      //TODO (SENDING TO SCOREBOARD AS A COMPLETE PACKET)
      // monitor_analysis_port.write(item);
    end   
  endtask : run_phase   
      
  task collect_data(input i2c_seq_item item);                           //DEFINING TASK COLLECT DATA FUNCTIONALITY
    get_7bit_addr();                                                    //COLLECTING 7-BIT SLAVE ADDRESS FROM MASTER
    `uvm_info(get_type_name(),$sformatf("MstrMon received address = %0h",item.slv_addr),UVM_LOW)
    
    @(posedge mvif.scl);
    item.rw = mvif.sda;                                              //COLLECTING READ OR WRITE BIT FROM MASTER
    `uvm_info(get_type_name(),$sformatf("MstrMon received read-write  bit = %0b",item.rw),UVM_LOW)
    
    if((item.slv_addr >= 7'h78) && (item.slv_addr <= 7'h7b)) begin     //CHECK FOR 10-BIT ADDRESS 
      @(posedge mvif.scl);
      #3us;
      ack = mvif.sda;
      `uvm_info(get_type_name(),$sformatf("MstrMon received ack or nak bit = %0b",ack),UVM_LOW) 
      
      flag = 1; 
    end
    
    @(posedge mvif.scl);                                    //COLLECTING ACK FROM SLAVE
    #3us;
    ack = mvif.sda;
    `uvm_info(get_type_name(),$sformatf("MstrMon received after 2nd byte ack or nak bit = %0b",ack),UVM_LOW) 
    
    
    if( (item.slv_addr == env_config_h.slv_addr))begin     //ADDRESS MATCHING 
      if(ack == 0) begin
        `uvm_info("i2c_m_monitor","Master monitor address matching successful",UVM_LOW)
      end
      else begin
        `uvm_fatal("i2c_m_monitor","MstrMon found Address is matching but slave is sending NACK")
      end
    end
        
    if(!ack) begin      
      if((item.rw == 1)&&(flag == 0)) begin
        get_8bit_data_rd();                               // TASK FOR 7-BIT READ TRANSACTION
      end
      
      if((item.rw == 0)&&(flag == 0)) begin 
        @(posedge mvif.scl);
        temp_data[7] = mvif.sda;  
        get_8bit_data_wr(temp_data);                      //TASK FOR 7-BIT WRITE TRANSACTION
      end  
      
      if((item.rw == 0)&&(flag == 1)) begin           
        check_start();                                    //CHECKING FOR REPEAT START
    end
    else  begin
      monitor_check_stop();                               //STOP CONDITION
    end         
    end
  endtask :collect_data           
    
  task  monitor_start();                                 //DEFINING START TASK FUNCTIONALITY
    forever begin
      @(negedge mvif.sda);
      
      if(mvif.scl == 1)begin
        start = 1;
        break;
      end
    end
  endtask : monitor_start
 
  task check_start();                                   //DEFINING CHECK_START TASK FOR 10-BIT FUNCTIONALITY
    @(posedge mvif.scl);
    #3us;
    temp_data[7]=mvif.sda;
 
  endtask : check_start
   
  task get_7bit_addr();                                //DEFINING TASK FOR GETTING SLAVE ADDRESS
    for(int i = 6; i >= 0; i--) begin
      @(posedge mvif.scl );
      item.slv_addr[i] = mvif.sda;                       //7-BIT ADDRESS
              
    end
  endtask : get_7bit_addr
	
  task get_8bit_data_wr(input bit [7:0]temp_data);     //DEFINING TASK FOR WRITE DATA FUNCTIONALITY
    do begin  
      
      for(int i = 6;i >= 0 ; i--) begin                // COLLECTING 8-BIT DATA
        @(posedge mvif.scl );
        temp_data[i] = mvif.sda;  
        `uvm_info(get_type_name(),$sformatf("MstrMon in Wr seq. received data bit %0b = %0d",i, temp_data[i]),UVM_HIGH)
      end
      
      `uvm_info(get_type_name(),$sformatf("--------MASTER MONITOR--WRITE SEQ DATA = %0h",temp_data),UVM_LOW)
      item.data.push_back(temp_data);                //PUSHING 8-BIT DATA INTO QUEUE
      
      @(posedge mvif.scl);                          //RECEIVING ACK FROM SLAVE
      ack = mvif.sda; 
      `uvm_info(get_type_name(),$sformatf("-------MASTER MONITOR WRITE SEQ RECEIVED ACK/NACK BIT = %0b",ack),UVM_LOW) 
      
      monitor_check_stop();                         //CHECKING FOR STOP CONDITION
      temp_data[7] = mvif.sda; 
      `uvm_info(get_type_name(),$sformatf("-------MASTER MONITOR WRITE SEQ RECEIVED STOP BIT = %0b",stopcheck),UVM_LOW)
      
      `uvm_info(get_type_name(), " ***********************MastrMon Wr seq I M WRITING TO SB", UVM_LOW)
      item.print();
      monitor_analysis_port.write(item);             //WRITING INTO SCOREBOARD
      
      if(repeat_start) begin                        //CHECKING FOR REPEAT START 
        collect_data(item);
        break;
      end
      
      if(stopcheck) begin
        `uvm_info(get_type_name(),"------MASTER MONITOR--WRITE SEQ STOP CONDITION",UVM_LOW)
      end
        
      if(stopcheck == 0 && ack == 1) begin
        `uvm_fatal("i2c_m_monitor","MstrMon found NAK in write seq, stop must be there after NAK")
      end
        
    end
    while(!stopcheck&&(ack == 0));
  endtask : get_8bit_data_wr
                    
  task get_8bit_data_rd();                            //DEFINING TASK FOR READ DATA FUNCTIONALITY
    bit [7:0] temp_data;
    @(posedge mvif.scl );
    temp_data[7] = mvif.sda;
    do begin
      
      for(int i = 6;i >= 0; i--) begin            // COLLECTING 8-BIT DATA
        @(posedge mvif.scl );
        temp_data[i] = mvif.sda;
      end
      
      `uvm_info(get_type_name(),$sformatf("--------MASTER MONITOR--READ SEQ DATA = %0h",temp_data),UVM_LOW)
      item.data.push_back(temp_data);            //PUSHING 8-BIT DATA INTO QUEUE
      
      @(negedge mvif.scl);                       //RECEIVING ACK FROM MASTER
      #3us;
      ack = mvif.sda;
      @(posedge mvif.scl);
      `uvm_info(get_type_name(),$sformatf("-------MASTER MONITOR READ SEQ RECEIVED ACK/NACK BIT = %0b",ack),UVM_LOW) 
      
      monitor_check_stop();                       //CHECKING FOR STOP CONDITION
      temp_data[7] = mvif.sda;
      `uvm_info(get_type_name(),$sformatf("-------MASTER MONITOR READ SEQ RECEIVED STOP BIT = %0b",stopcheck),UVM_LOW)
      
      `uvm_info(get_type_name(), " ***********************MastrMon Rd seq I M WRITING TO SB", UVM_LOW)
      item.print();
      monitor_analysis_port.write(item);         //WRITING INTO SCOREBOARD   
      
      if(repeat_start) begin                    //CHECKING FOR REPEAT START
        collect_data(item);
        break;
      end  
      
      if(stopcheck) begin
        `uvm_info(get_type_name(),"------MASTER MONITOR--READ SEQ STOP CONDITION",UVM_LOW)  
      end
        
      if(stopcheck == 1 && ack == 0) begin
        `uvm_fatal("i2c_m_monitor","MstrMon Rd seq :: Nak should come before stop condition")
      end
        
      if(stopcheck == 0 && (ack == 1 && repeat_start == 0)) begin
        `uvm_fatal("i2c_m_monitor","MstrMon Rd seq  :: stop must come after nack")
      end        
    end
    while(!stopcheck && (ack == 0));   
  endtask : get_8bit_data_rd
               
  task monitor_check_stop(); 
    fork 
      begin                                 //CHECKING STOP CONDITION
        @(posedge mvif.scl);  
        @(posedge mvif.sda);
        stopcheck = 1;
      end
      
      begin                             
        @(posedge mvif.scl);
        @(negedge mvif.scl);
        stopcheck = 0;
        repeat_start = 0;
      end
      
      begin                             //CHECKING REPEAT START CONDITION
        @(posedge mvif.scl);  
        @(negedge mvif.sda);
        repeat_start = 1;
      end
    join_any
    disable fork;
  endtask : monitor_check_stop
          
          
endclass : i2c_m_monitor
          
