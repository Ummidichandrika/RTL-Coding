`uvm_analysis_imp_decl(_actdata)
`uvm_analysis_imp_decl(_expdata)

class i2c_scoreboard extends uvm_scoreboard;
  int act_size_int;
  int exp_size_int;
  `uvm_component_utils(i2c_scoreboard)
 
  //Declaring Queue for storing expected and actual data
  i2c_seq_item act_data_queue[$],exp_data_queue[$]; 
  
  //Object handle for comparing expected and actual data 
  i2c_seq_item act_data_h,exp_data_h;
  
  uvm_analysis_imp_actdata#(i2c_seq_item,i2c_scoreboard) master_mon_export;//Analysis port from master monitor 
  uvm_analysis_imp_expdata#(i2c_seq_item,i2c_scoreboard) slave_mon_export;//Analysis port from slave monitor
  
  //Constructing
  function new(string name = "i2c_scoreboard",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  //Build Phase
  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     master_mon_export = new("master_mon_export",this);
     slave_mon_export  = new("slave_mon_export",this);
     act_data_h = i2c_seq_item::type_id::create("act_data_h");
     exp_data_h = i2c_seq_item::type_id::create("exp_data_h");
   endfunction
  
  //Packet received from master monitor and pushed into act_data_queue
  function write_actdata(input i2c_seq_item act_data);
    act_data_queue.push_back(act_data); // Pusing into queue
    `uvm_info(get_type_name(), "I am in write_actdata", UVM_LOW)
  endfunction
 
  //Packet received from slave monitor and pushed into exp_data_queue
  function write_expdata(input i2c_seq_item exp_data);
    exp_data_queue.push_back(exp_data); // Pushing into Queue
    `uvm_info(get_type_name(), "I am in write_expdata", UVM_LOW)
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      
      //Waiting for Queue to get size from master and slave monitor data
      wait(act_data_queue.size() != 0 && exp_data_queue.size() != 0);
        
      //Poping out data from queue to local handles for comparision     
      act_data_h = act_data_queue.pop_front();
      exp_data_h = exp_data_queue.pop_front();
   
      act_size_int = act_data_h.data.size();
      exp_size_int= exp_data_h.data.size();
         
      if(act_data_h.compare(exp_data_h)) begin
        PASS();
      end 
      else begin
        FAIL();
      end
     
    end
   
  endtask
  
  function void PASS();
     
    data_size_compare(); 

    if(!act_data_h.rw && !exp_data_h.rw) begin //Check for write
      `uvm_info("PASS","************************************************ WRITE SUCCESS ******************************",UVM_MEDIUM)
      `uvm_info("PASS",$sformatf("************* Comparison info act data is %0h exp data is %0h  **********************",act_data_h.data.pop_front(),exp_data_h.data.pop_front()),UVM_MEDIUM)
      `uvm_info("PASS","************************************************ SUCCESS ******************************",UVM_MEDIUM)
      `uvm_info("PACKET",$psprintf("Comparison info:\t %s   \t %s ",act_data_h.sprint(),exp_data_h.sprint()),UVM_MEDIUM)
    end 
    else if (act_data_h.rw && exp_data_h.rw) begin  
      `uvm_info("PASS","************************************************ READ SUCCESS ******************************",UVM_MEDIUM)
      `uvm_info("PASS",$sformatf("************* Comparison info act data is %0h exp data is %0h  **********************",act_data_h.data.pop_front(),exp_data_h.data.pop_front()),UVM_MEDIUM)
      `uvm_info("PASS","************************************************ SUCCESS ******************************",UVM_MEDIUM)
      `uvm_info("PACKET",$psprintf("Comparison info:\t %s   \t %s ",act_data_h.sprint(),exp_data_h.sprint()),UVM_MEDIUM)
    end  
   endfunction  
  
   function void FAIL();
     
     if(act_data_h.slv_addr != exp_data_h.slv_addr)
       `uvm_fatal("ERROR",$sformatf("Address is not matching . Master sent address = %0h  Slave Received Address = %0h",act_data_h.slv_addr,exp_data_h.slv_addr))
     
     data_size_compare(); 
       
     if(!act_data_h.rw && !exp_data_h.rw) begin //Check for write
       `uvm_info("FAIL","+++++++++++++++++++++++++++++++++++++++++++++++++ WRITE FAILED +++++++++++++++++++++++++++++++",UVM_MEDIUM);
       `uvm_info("FAIL",$sformatf("************* Comparison info act data is %0h exp data is %0h  **********************",act_data_h.data.pop_front(),exp_data_h.data.pop_front()),UVM_MEDIUM);
       `uvm_info("FAIL","+++++++++++++++++++++++++++++++++++++++++++++++++ FAILED +++++++++++++++++++++++++++++++",UVM_MEDIUM);   
       `uvm_info("PACKET",$psprintf("Comparison info:\t %s   \t %s ",act_data_h.sprint(),exp_data_h.sprint()),UVM_MEDIUM);
       `uvm_fatal("ERROR","Data mismatch at the master and slave driver :( ") 
     end
     else if (act_data_h.rw && exp_data_h.rw) begin //For Read
       `uvm_info("FAIL","+++++++++++++++++++++++++++++++++++++++++++++++++ READ FAILED +++++++++++++++++++++++++++++++",UVM_MEDIUM);
       `uvm_info("FAIL",$sformatf("************* Comparison info act data is %0h exp data is %0h  **********************",act_data_h.data.pop_front(),exp_data_h.data.pop_front()),UVM_MEDIUM);
       `uvm_info("FAIL","+++++++++++++++++++++++++++++++++++++++++++++++++ FAILED +++++++++++++++++++++++++++++++",UVM_MEDIUM);
     end 
     else begin
       `uvm_fatal("ERROR",$sformatf("Read-Write bit is not matching act data rw = %0d  exp data rw = %0d",act_data_h.rw,exp_data_h.rw))
     end
         
   endfunction
  
   function void data_size_compare();   
     if(act_size_int != exp_size_int)
       `uvm_fatal("ERROR",$sformatf("Data size is not matching . Master data size  = %0d  Slave Received data size = %0d",act_size_int,exp_size_int))
          
   endfunction : data_size_compare
 
endclass
