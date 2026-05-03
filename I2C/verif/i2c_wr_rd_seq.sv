//-------------------------------------WRITE_THEN_READ------------------------------//

class i2c_wr_rd_seq extends  uvm_sequence#(i2c_seq_item);
  `uvm_object_utils(i2c_wr_rd_seq)
  
  function new(string name="i2c_wr_rd_seq");
    super.new(name);
  endfunction : new
  
  task body();
    begin
      $display("I am in i2c_wr_rd_seq");
      `uvm_do_with(req,{req.rw==1'b0;req.data.size()==8'h5; req.data[0]==8'hEA; req.repeated_st==1;req.enable==1;})
      //`uvm_do_with(req,{req.rw==1'b1;  req.repeated_st==0;})
    end
  endtask : body

endclass : i2c_wr_rd_seq
