`include "uvm_macros.svh"
`include "i2c_pkg.sv"


module tb_top;  
  
  import uvm_pkg::*;
  import i2c_pkg::*;
  
  tri1  scl;
  tri1 sda;
  logic clock,rst;
  
  i2c_minterface mvif(.scl(scl),.sda(sda));
  i2c_sinterface svif(.scl(scl),.sda(sda));
  
  i2c_master master(.scl(mvif.scl),.sda(mvif.sda),.clk(clock),.rst(rst),.addr(mvif.addr),.data_in(mvif.data_in),.enable(mvif.enable),.rw(mvif.rw));
    i2c_slave  slave(.scl(svif.scl), .sda(svif.sda));

  
  initial begin rst=1; clock = 0; #20 rst=0;end
  always #1 clock = ~clock;
    
  initial begin   
    uvm_config_db#(virtual i2c_minterface)::set(uvm_root::get(), "*",  "mvif" , mvif);
    uvm_config_db#(virtual i2c_sinterface)::set(uvm_root::get(), "*",  "svif" , svif);
  end
  
  initial begin 
    
    run_test("i2c_wr_rd_test");
	uvm_top.finish_on_completion=1;
  end
  
  initial begin
	$dumpfile("dump.vcd"); 
	$dumpvars;
  end

endmodule
