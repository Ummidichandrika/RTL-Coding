package i2c_pkg;
  import uvm_pkg::*;

  `include "i2c_seq_item.sv"
  `include "i2c_wr_rd_sequence.sv"
  `include "i2c_m_sequencer.sv"
  `include "i2c_env_config.sv"
  `include "i2c_m_driver.sv"
  `include "i2c_s_driver.sv"
  `include "i2c_s_sequencer.sv"
  `include "i2c_m_monitor.sv"
  `include "i2c_s_monitor.sv"
  `include "i2c_m_agent.sv"
  `include "i2c_s_agent.sv"
  `include "i2c_scoreboard.sv"
  `include "i2c_env.sv"
  `include "i2c_base_test.sv"

  `include  "i2c_wr_rd_test.sv"

endpackage : i2c_pkg
