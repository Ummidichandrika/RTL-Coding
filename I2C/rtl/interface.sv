`include "i2c_master.sv"
`include "i2c_slave.sv"
interface i2c_minterface(tri1 sda,scl);
  logic [6:0] addr;
  logic [7:0] data_in;
  logic rw,enable;
endinterface : i2c_minterface

interface i2c_sinterface(tri1 scl, sda);
endinterface : i2c_sinterface
