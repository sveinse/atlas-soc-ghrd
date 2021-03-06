
//`define ENABLE_CLK

module ghrd_top 
#(
        parameter MEM_A_WIDTH,
        parameter MEM_D_WIDTH,
        parameter MEM_BA_WIDTH
)
(
    //Clocks and Resets
	input		fpga_clk1_50,
	input		fpga_clk2_50,         
	input		fpga_clk3_50,
`ifdef ENABLE_CLK
	output		clk_i2c_scl,
	inout 		clk_i2c_sda,
`endif /*ENABLE_CLK*/                       
 	
    // HPS memory controller ports
	output wire [MEM_A_WIDTH - 1:0] 	hps_memory_mem_a,                           
	output wire [MEM_BA_WIDTH - 1:0]	hps_memory_mem_ba,                          
	output wire       			hps_memory_mem_ck,                          
	output wire        			hps_memory_mem_ck_n,                        
	output wire        			hps_memory_mem_cke,                         
	output wire        			hps_memory_mem_cs_n,                        
	output wire        			hps_memory_mem_ras_n,                       
	output wire        			hps_memory_mem_cas_n,                       
	output wire        			hps_memory_mem_we_n,                        
	output wire        			hps_memory_mem_reset_n,                     
	inout  wire [MEM_D_WIDTH - 1:0]		hps_memory_mem_dq,                          
	inout  wire [(MEM_D_WIDTH/8) -1:0]	hps_memory_mem_dqs,                         
	inout  wire [(MEM_D_WIDTH/8) -1:0]	hps_memory_mem_dqs_n,                       
	output wire        			hps_memory_mem_odt,                         
	output wire [(MEM_D_WIDTH/8) -1:0] 	hps_memory_mem_dm,                          
	input  wire        			hps_memory_oct_rzqin,                       
    // HPS peripherals
	output wire        hps_emac1_TX_CLK,   
	output wire        hps_emac1_TXD0,     
	output wire        hps_emac1_TXD1,     
	output wire        hps_emac1_TXD2,     
	output wire        hps_emac1_TXD3,     
	input  wire        hps_emac1_RXD0,     
	inout  wire        hps_emac1_MDIO,     
	output wire        hps_emac1_MDC,      
	input  wire        hps_emac1_RX_CTL,   
	output wire        hps_emac1_TX_CTL,   
	input  wire        hps_emac1_RX_CLK,   
	input  wire        hps_emac1_RXD1,     
	input  wire        hps_emac1_RXD2,     
	input  wire        hps_emac1_RXD3, 
	inout  wire        hps_sdio_CMD,       
	inout  wire        hps_sdio_D0,        
	inout  wire        hps_sdio_D1,        
	output wire        hps_sdio_CLK,       
	inout  wire        hps_sdio_D2,        
	inout  wire        hps_sdio_D3,        
	inout  wire        hps_usb1_D0,        
	inout  wire        hps_usb1_D1,        
	inout  wire        hps_usb1_D2,        
	inout  wire        hps_usb1_D3,        
	inout  wire        hps_usb1_D4,        
	inout  wire        hps_usb1_D5,        
	inout  wire        hps_usb1_D6,        
	inout  wire        hps_usb1_D7,        
	input  wire        hps_usb1_CLK,       
	output wire        hps_usb1_STP,       
	input  wire        hps_usb1_DIR,       
	input  wire        hps_usb1_NXT,       
	input  wire        hps_uart0_RX,       
	output wire        hps_uart0_TX,            
	output wire        hps_spim1_CLK,
	output wire        hps_spim1_MOSI,
	input  wire        hps_spim1_MISO,
	output wire        hps_spim1_SS0,
	inout  wire        hps_i2c0_SDA,
	inout  wire        hps_i2c0_SCL,
	inout  wire        hps_i2c1_SDA,
	inout  wire        hps_i2c1_SCL,
	inout  wire        hps_conv_usb_n,
	inout  wire        hps_emac1_int_n,
	inout  wire        hps_ltc_gpio,
	inout  wire        hps_led,
	inout  wire        hps_key,
	inout  wire        hps_gsensor_int,
	
    // FPGA GPIO
	input  wire [1:0]  fpga_key_pio,
	output wire [7:0]  fpga_led_pio,
	input  wire [3:0]  fpga_dipsw_pio,

    // ADC  
	output  wire       adc_convst,
	output  wire       adc_sck,
	output  wire       adc_sdi,
	input   wire       adc_sdo,
	
    // Android IO    
      inout  wire [15:0]   arduino_io,
      inout  wire          arduino_reset_n,

    // GPIO
      inout  wire [35:0]   gpio_0,
      inout  wire [35:0]   gpio_1	
);

//REG/WIRE Declarations
wire		hps_fpga_reset_n;
wire [2:0]	hps_reset_req;
wire		hps_cold_reset;
wire		hps_warm_reset;
wire		hps_debug_reset;
wire [27:0] 	stm_hw_events;

wire [1:0] fpga_debounced_buttons;
wire [7:0] fpga_led_internal;

//assignments
assign stm_hw_events    = {{14{1'b0}}, fpga_dipsw_pio, fpga_led_internal, fpga_debounced_buttons};

assign arduino_io = 16'hZZZZ;
assign arduino_reset_n = 1'b1;

assign gpio_0 = 36'hZZZZZZZZZ;
assign gpio_1 = 36'hZZZZZZZZZ;
assign fpga_led_pio = fpga_led_internal;

assign adc_convst = 1'b0;
assign adc_sck = 1'b0;
assign adc_sdi = 1'b0;


// SoC sub-system module
soc_system soc_inst (
  //Clocks & Resets
  .clk_clk                               (fpga_clk1_50),
  .reset_reset_n                         (hps_fpga_reset_n),
  .hps_0_h2f_clk_clk                     (),
  .hps_0_h2f_reset_reset_n               (hps_fpga_reset_n),
  .hps_0_f2h_warm_reset_req_reset_n      (~hps_warm_reset),
  .hps_0_f2h_debug_reset_req_reset_n     (~hps_debug_reset),
  .hps_0_f2h_cold_reset_req_reset_n      (~hps_cold_reset),
  
  //DRAM
  .memory_mem_a                          (hps_memory_mem_a),                               
  .memory_mem_ba                         (hps_memory_mem_ba),                         
  .memory_mem_ck                         (hps_memory_mem_ck),                         
  .memory_mem_ck_n                       (hps_memory_mem_ck_n),                       
  .memory_mem_cke                        (hps_memory_mem_cke),                        
  .memory_mem_cs_n                       (hps_memory_mem_cs_n),                       
  .memory_mem_ras_n                      (hps_memory_mem_ras_n),                      
  .memory_mem_cas_n                      (hps_memory_mem_cas_n),                      
  .memory_mem_we_n                       (hps_memory_mem_we_n),                       
  .memory_mem_reset_n                    (hps_memory_mem_reset_n),                    
  .memory_mem_dq                         (hps_memory_mem_dq),                         
  .memory_mem_dqs                        (hps_memory_mem_dqs),                        
  .memory_mem_dqs_n                      (hps_memory_mem_dqs_n),                      
  .memory_mem_odt                        (hps_memory_mem_odt),                            
  .memory_mem_dm                         (hps_memory_mem_dm),                         
  .memory_oct_rzqin                      (hps_memory_oct_rzqin),      
  
  //HPS Peripherals
  //Emac1
  .hps_0_hps_io_hps_io_emac1_inst_TX_CLK (hps_emac1_TX_CLK), 
  .hps_0_hps_io_hps_io_emac1_inst_TXD0   (hps_emac1_TXD0),   
  .hps_0_hps_io_hps_io_emac1_inst_TXD1   (hps_emac1_TXD1),   
  .hps_0_hps_io_hps_io_emac1_inst_TXD2   (hps_emac1_TXD2),   
  .hps_0_hps_io_hps_io_emac1_inst_TXD3   (hps_emac1_TXD3),   
  .hps_0_hps_io_hps_io_emac1_inst_RXD0   (hps_emac1_RXD0),   
  .hps_0_hps_io_hps_io_emac1_inst_MDIO   (hps_emac1_MDIO),   
  .hps_0_hps_io_hps_io_emac1_inst_MDC    (hps_emac1_MDC),    
  .hps_0_hps_io_hps_io_emac1_inst_RX_CTL (hps_emac1_RX_CTL), 
  .hps_0_hps_io_hps_io_emac1_inst_TX_CTL (hps_emac1_TX_CTL), 
  .hps_0_hps_io_hps_io_emac1_inst_RX_CLK (hps_emac1_RX_CLK), 
  .hps_0_hps_io_hps_io_emac1_inst_RXD1   (hps_emac1_RXD1),   
  .hps_0_hps_io_hps_io_emac1_inst_RXD2   (hps_emac1_RXD2),   
  .hps_0_hps_io_hps_io_emac1_inst_RXD3   (hps_emac1_RXD3),
  //SDMMC
  .hps_0_hps_io_hps_io_sdio_inst_CMD     (hps_sdio_CMD),     
  .hps_0_hps_io_hps_io_sdio_inst_D0      (hps_sdio_D0),      
  .hps_0_hps_io_hps_io_sdio_inst_D1      (hps_sdio_D1),      
  .hps_0_hps_io_hps_io_sdio_inst_CLK     (hps_sdio_CLK),     
  .hps_0_hps_io_hps_io_sdio_inst_D2      (hps_sdio_D2),      
  .hps_0_hps_io_hps_io_sdio_inst_D3      (hps_sdio_D3),
  //USB1
  .hps_0_hps_io_hps_io_usb1_inst_D0      (hps_usb1_D0),      
  .hps_0_hps_io_hps_io_usb1_inst_D1      (hps_usb1_D1),      
  .hps_0_hps_io_hps_io_usb1_inst_D2      (hps_usb1_D2),      
  .hps_0_hps_io_hps_io_usb1_inst_D3      (hps_usb1_D3),      
  .hps_0_hps_io_hps_io_usb1_inst_D4      (hps_usb1_D4),      
  .hps_0_hps_io_hps_io_usb1_inst_D5      (hps_usb1_D5),      
  .hps_0_hps_io_hps_io_usb1_inst_D6      (hps_usb1_D6),      
  .hps_0_hps_io_hps_io_usb1_inst_D7      (hps_usb1_D7),      
  .hps_0_hps_io_hps_io_usb1_inst_CLK     (hps_usb1_CLK),     
  .hps_0_hps_io_hps_io_usb1_inst_STP     (hps_usb1_STP),     
  .hps_0_hps_io_hps_io_usb1_inst_DIR     (hps_usb1_DIR),     
  .hps_0_hps_io_hps_io_usb1_inst_NXT     (hps_usb1_NXT),
  //UART0
  .hps_0_hps_io_hps_io_uart0_inst_RX     (hps_uart0_RX),     
  .hps_0_hps_io_hps_io_uart0_inst_TX     (hps_uart0_TX),     
  //SPIM1
  .hps_0_hps_io_hps_io_spim1_inst_CLK    (hps_spim1_CLK),
  .hps_0_hps_io_hps_io_spim1_inst_MOSI   (hps_spim1_MOSI),
  .hps_0_hps_io_hps_io_spim1_inst_MISO   (hps_spim1_MISO),
  .hps_0_hps_io_hps_io_spim1_inst_SS0    (hps_spim1_SS0),
  //I2C 0,1
  .hps_0_hps_io_hps_io_i2c0_inst_SDA     (hps_i2c0_SDA),
  .hps_0_hps_io_hps_io_i2c0_inst_SCL     (hps_i2c0_SCL),
  .hps_0_hps_io_hps_io_i2c1_inst_SDA     (hps_i2c1_SDA),
  .hps_0_hps_io_hps_io_i2c1_inst_SCL     (hps_i2c1_SCL),
  //GPIO
  .hps_0_hps_io_hps_io_gpio_inst_GPIO09  (hps_conv_usb_n),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO35  (hps_emac1_int_n),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO40  (hps_ltc_gpio),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO53  (hps_led),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO54  (hps_key),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO61  (hps_gsensor_int),
  
  //STM
  .hps_0_f2h_stm_hw_events_stm_hwevents  (stm_hw_events),  
 
  //PIOs
  .button_pio_export                     (fpga_debounced_buttons),
  .dipsw_pio_export                      (fpga_dipsw_pio),
  .led_pio_export                        (fpga_led_internal)
);  


// Debounce logic to clean out glitches within 1ms
debounce debounce_inst (
  .clk                                  (fpga_clk1_50),
  .reset_n                              (hps_fpga_reset_n),  
  .data_in                              (fpga_key_pio),
  .data_out                             (fpga_debounced_buttons)
);
  defparam debounce_inst.WIDTH = 2;
  defparam debounce_inst.POLARITY = "LOW";
  defparam debounce_inst.TIMEOUT = 50000;               // at 50Mhz this is a debounce time of 1ms
  defparam debounce_inst.TIMEOUT_WIDTH = 16;            // ceil(log2(TIMEOUT))
  
// Source/Probe megawizard instance
hps_reset hps_reset_inst (
  .source_clk (fpga_clk1_50),
  .source     (hps_reset_req)
);

altera_edge_detector pulse_cold_reset (
  .clk       (fpga_clk1_50),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[0]),
  .pulse_out (hps_cold_reset)
);
  defparam pulse_cold_reset.PULSE_EXT = 6;
  defparam pulse_cold_reset.EDGE_TYPE = 1;
  defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_warm_reset (
  .clk       (fpga_clk1_50),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[1]),
  .pulse_out (hps_warm_reset)
);
  defparam pulse_warm_reset.PULSE_EXT = 2;
  defparam pulse_warm_reset.EDGE_TYPE = 1;
  defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY = 1;
  
altera_edge_detector pulse_debug_reset (
  .clk       (fpga_clk1_50),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[2]),
  .pulse_out (hps_debug_reset)
);
  defparam pulse_debug_reset.PULSE_EXT = 32;
  defparam pulse_debug_reset.EDGE_TYPE = 1;
  defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;

endmodule

