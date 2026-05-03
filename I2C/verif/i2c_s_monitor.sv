
class i2c_s_monitor extends uvm_monitor;
  
  `uvm_component_utils(i2c_s_monitor)
  
  i2c_env_config env_config_h;
  virtual  i2c_sinterface svif;
  
  i2c_seq_item tx;
  uvm_analysis_port #(i2c_seq_item)  aport;
  
  bit [7:0] t_data;	  				                                                        //to store temporary data
  bit ack;
  bit stop_c;
  bit start;
  bit repeat_start = 0;
  
  function new(string name = "i2c_s_monitor", uvm_component parent = null);                //new function
    super.new(name,parent);
    aport = new("aport",this);		
  endfunction : new

  function void build_phase   (uvm_phase phase);                                          //function build_phase
     super.build_phase(phase);
		
    if(!uvm_config_db #(virtual interface  i2c_sinterface) :: get(this, "",  "svif", svif) ) begin
       `uvm_fatal("i2c_s_monitor", "SlvMon i2c_interface did not get")
     end

     if(!uvm_config_db #(i2c_env_config)::get(this,"","env_config_h",env_config_h))  begin
       `uvm_fatal("i2c_s_monitor","SlvMon cannot get the env config")
     end
                        
  endfunction : build_phase
 
  task run_phase  (uvm_phase phase);                                                       //task run phase
    repeat(1) begin
      tx=new();
      monitor_start();      	 		                                                   // check for start condition
      start=0;
      `uvm_info(get_type_name(),"SlvMon received start condition",UVM_LOW) 
      collect_data(tx);
    end
  endtask : run_phase
       
  task collect_data(input i2c_seq_item tx);
    monitor_7bit_addr(); 			                                                       // collecting address
    `uvm_info(get_type_name(),$sformatf("SlvMon received address = %0h",tx.slv_addr),UVM_LOW)
    @(posedge svif.scl);   			                                                       // read or write
    tx.rw=svif.sda;
    `uvm_info(get_type_name(),$sformatf("SlvMon received read-write  bit = %0b",tx.rw),UVM_LOW)
    
    @(posedge svif.scl);                                                                    //receiving ack from slave
    ack=svif.sda;	
    `uvm_info(get_type_name(),$sformatf("SlvMon Received Ack or Nak bit after address :: as : %0b",ack),UVM_LOW)   
    address_match(ack);                                                                     //task for address matching
    if(ack==0) begin
      if(tx.rw==1) begin
        read_data();                                                                       //read task
      end
      
      if(tx.rw==0) begin
        @(posedge svif.scl);
        t_data[7] = svif.sda;
        write_data(t_data);                                                                //write task
      end
    end
      
  endtask    
        
  task monitor_start ();                                                                       //checking for start condition
    forever begin
      @(negedge svif.sda);
      if(svif.scl==1'b1)begin
        start=1;
        break;
      end
    end
  endtask : monitor_start
                     
  task expect_stop();         
    fork
      
      begin                                                                                //checking for stop condition
        @(posedge svif.scl);
        @(posedge svif.sda);
        stop_c=1;      
      end
      
      begin                                                                                //checking for repeat start condition
        @(posedge svif.scl);
        @(negedge svif.sda);
        repeat_start=1;
      end
      
      begin
        @(posedge svif.scl);
        @(negedge svif.scl);
        stop_c=0;
        repeat_start=0;
      end
      
    join_any  
    disable fork;      
  endtask : expect_stop
      
  
  task monitor_7bit_addr();                                                                       //getting address
    for(int i=6;i>=0;i--) begin
      @(posedge svif.scl);
      tx.slv_addr[i]=svif.sda;
     
    end
  endtask : monitor_7bit_addr
          
  
  task address_match(bit ACK);                                                                   //address matching
    if(tx.slv_addr ==env_config_h.slv_addr) begin    
      if(ACK==0) begin
        `uvm_info(get_type_name(),"SlvMon Address Match Sucessfull",UVM_LOW)
      end
	  else begin
        `uvm_info(get_type_name(),"SlvMon  Address Match Not Sucessfull",UVM_LOW)
      end
    end
  endtask : address_match    
  
  task read_data( );                                                                              //collecting the data
    @(posedge svif.scl);
    #4us;
    t_data[7] = svif.sda;
    do begin    
      for(int i=6;i>=0;i--) begin                                                                 //get data
        @(posedge svif.scl);
        t_data[i]=svif.sda;
      end 
      `uvm_info(get_type_name(),$sformatf("#############SlvMon in Rd. seq. received Data byte =: %0h",t_data),UVM_LOW)
      tx.data.push_back(t_data);                                                                 //push data to queue
      @(negedge svif.scl);
      #3us;
      ack=svif.sda;
      @(posedge svif.scl);
      `uvm_info(get_type_name(),$sformatf("*******SlvMon in Rd. seq =: %0b",ack ),UVM_LOW)
      expect_stop();                                                                             //checking for stop condition
      t_data[7] = svif.sda;
      `uvm_info(get_type_name(),$sformatf("*******SlvMon in Rd. seq repeat start =: %0b",repeat_start ),UVM_LOW)
      `uvm_info(get_type_name(),$sformatf("*******SlvMon in Rd. seq stop_c =: %0b",stop_c ),UVM_LOW)
      `uvm_info(get_type_name(), " *******************SlvMon rd seq   I M WRITING TO SB", UVM_LOW)
      tx.print();
      aport.write (tx);			                                                         	     // sending data to scoreboard     
      
      if(repeat_start)begin
        collect_data(tx);       
        break;
      end
      
      if(!((stop_c==0)&&(ack==0))) begin
        break; 
      end
    end
    while(1);   
  endtask
  
  task write_data(input bit [7:0]t_data);                                                                //collecting data
    do begin
      for (int i=6;i>=0;i--) begin                                                                      //get data
        @(posedge svif.scl);
        t_data[i]=svif.sda;
        `uvm_info(get_type_name(), $sformatf("SlvMon in Wr seq. received data bit %0b = %0d",i, t_data[i]), UVM_HIGH)
      end
      tx.data.push_back (t_data);                                                                      //push data to queue
      `uvm_info(get_type_name(), $sformatf("SlvMon in Wr seq. received data byte = %0h ", t_data), UVM_LOW)
      @(posedge svif.scl)
      ack=svif.sda;
      `uvm_info(get_type_name(), $sformatf("SlvMon in Wr seq. received ack nak bit as  = %0b", ack), UVM_LOW)
      expect_stop();                                                                                //checking for stop condition
      t_data[7] = svif.sda;
      `uvm_info(get_type_name(), " *******************SlvMon wr seq I M WRITING TO SB", UVM_LOW)
      tx.print();
      aport.write (tx);                                                                    // sending data to scoreboard   
      
      if(repeat_start) begin
        `uvm_info(get_type_name(), "=============SLAVE MONITOR IN 7 BIT=================", UVM_LOW)
        collect_data(tx);
        break;
      end
      `uvm_info(get_type_name(), $sformatf("SlvMon in Wr seq. stop_c= %0b", stop_c), UVM_LOW)
      
      if (ack==1&&stop_c==0) begin
        `uvm_fatal("i2c_s_monitor","SlvMon  in Wr seq. stop_c must come after nack")   
      end
    end  
    while((!stop_c)&&(ack==0));
  endtask
            
endclass 
