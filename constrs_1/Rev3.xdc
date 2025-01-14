set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

####################################################################################################################
#                                               CLOCK 100MHz                                                       #
####################################################################################################################
##Clock Signal
set_property -dict { PACKAGE_PIN "H4"    IOSTANDARD LVCMOS33       SLEW FAST} [get_ports { clk100 }]     ;     
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk100]
##HDMI in 1080p or 720p or 1080p@50
#create_clock -add -name hdmi_clk -period 6.734 -waveform {0 5} [get_ports hdmi_rx_clk_p]  
create_clock -add -name hdmi_clk -period 13.000 -waveform {0 5} [get_ports hdmi_rx_clk_p] 
#create_clock -add -name hdmi_clk -period 8.08080808081 -waveform {0 5} [get_ports hdmi_rx_clk_p] 

# ignore inter-clock path 
set_false_path -from [get_clocks sys_clk_pin] -to [get_clocks -of_objects [get_pins i_hdmi_io/i_hdmi_input/hdmi_MMCME2_BASE_inst/CLKOUT0]]
set_max_delay -from [get_pins {i_hdmi_io/i_clk_sel/cnt_reg[8]/C}] -to [get_pins i_hdmi_io/i_clk_sel/lo_reg/D] 100.0
set_max_delay -from [get_pins {i_hdmi_io/i_clk_sel/cnt_reg[8]/C}] -to [get_pins i_hdmi_io/i_clk_sel/hi_reg/D] 100.0
set_false_path -from [get_clocks -of_objects [get_pins ref_clk_pll/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins i_hdmi_io/i_hdmi_input/hdmi_MMCME2_BASE_inst/CLKOUT0]] 
#set_false_path -from [get_clocks -of_objects [get_pins ref_clk_pll/inst/mmcm_adv_inst/CLKOUT1]]-to   [get_clocks clk_pixel_raw]
#set_false_path -from [get_clocks clk_pixel_raw] -to [get_clocks -of_objects [get_pins ref_clk_pll/inst/mmcm_adv_inst/CLKOUT1]]
#set_false_path -from [get_clocks -of_objects [get_pins ref_clk_pll/inst/mmcm_adv_inst/CLKOUT2]] -to  [get_clocks clk_pixel_raw]
#set_false_path -from  [get_clocks clk_pixel_raw] -to [get_clocks -of_objects [get_pins ref_clk_pll/inst/mmcm_adv_inst/CLKOUT2]]
#set_false_path -from [get_clocks -of_objects [get_pins ref_clk_pll/inst/mmcm_adv_inst/CLKOUT3]] -to  [get_clocks clk_pixel_raw]
#set_false_path -from  [get_clocks clk_pixel_raw] -to [get_clocks -of_objects [get_pins ref_clk_pll/inst/mmcm_adv_inst/CLKOUT3]]
# set CE false path
set_max_delay 26.0 -from [get_pins {i_hdmi_io/i_hdmi_input/CE_Delay/m_reg[7]__0/C}] -to [get_pins i_hdmi_io/i_hdmi_input/ch1/i_deser/ISERDESE2_slave/CE1] 
set_max_delay 26.0 -from [get_pins {i_hdmi_io/i_hdmi_input/CE_Delay/m_reg[7]__0/C}] -to [get_pins i_hdmi_io/i_hdmi_input/ch2/i_deser/ISERDESE2_slave/CE1] 
set_max_delay 26.0 -from [get_pins {i_hdmi_io/i_hdmi_input/CE_Delay/m_reg[7]__0/C}] -to [get_pins i_hdmi_io/i_hdmi_input/ch1/i_deser/ISERDESE2_master/CE1] 
set_max_delay 26.0 -from [get_pins {i_hdmi_io/i_hdmi_input/CE_Delay/m_reg[7]__0/C}] -to [get_pins i_hdmi_io/i_hdmi_input/ch0/i_deser/ISERDESE2_slave/CE1] 
set_max_delay 26.0 -from [get_pins {i_hdmi_io/i_hdmi_input/CE_Delay/m_reg[7]__0/C}] -to [get_pins i_hdmi_io/i_hdmi_input/ch0/i_deser/ISERDESE2_master/CE1] 
set_max_delay 26.0 -from [get_pins {i_hdmi_io/i_hdmi_input/CE_Delay/m_reg[7]__0/C}] -to [get_pins i_hdmi_io/i_hdmi_input/ch2/i_deser/ISERDESE2_master/CE1] 
# exempt IOs from clocking constraint
set_false_path -through [get_ports BTNL]
set_false_path -through [get_ports BTNT]
set_false_path -through [get_ports en[*]]
set_false_path -through [get_ports seg[*]]
set_false_path -through [get_ports led[*]]
####################################################################################################################
#                                               Micro SD                                                           #
####################################################################################################################
set_property -dict { PACKAGE_PIN "R16"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { sd_clk }];                      # IO_L22N_T3_A04_D20_14         Sch = SD_SCK
set_property -dict { PACKAGE_PIN "R18"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { sd_cs  }];                      # IO_L20P_T3_A08_D24_14         Sch = SD_CS
set_property -dict { PACKAGE_PIN "P15"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { sd_miso}];                      # IO_L22P_T3_A05_D21_14         Sch = SD_SDO
set_property -dict { PACKAGE_PIN "T18"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { sd_mosi}];                      # IO_L20N_T3_A07_D23_14         Sch = SD_SDI
####################################################################################################################
#                                               Push Buttons                                                       #
####################################################################################################################
set_property -dict { PACKAGE_PIN "P20"  IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { BTNT }];                     # IO_0_14                       Sch = SW0
set_property -dict { PACKAGE_PIN "P19"  IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { BTNL }];                     # IO_L5P_T0_D06_14              Sch = SW1
#set_property -dict { PACKAGE_PIN "P17"  IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { sw_in[2] }];                     # IO_L21N_T3_DQS_A06_D22_14     Sch = SW2
set_property -dict { PACKAGE_PIN "N17"  IOSTANDARD LVCMOS33    SLEW FAST} [get_ports {BTNR }];                     # IO_L21P_T3_DQS_14             Sch = SW3


####################################################################################################################
#                                               LEDs                                                               #
####################################################################################################################
set_property -dict { PACKAGE_PIN "K17"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { led[0] }];                      # IO_L21P_T3_DQS_15             Sch = led0
set_property -dict { PACKAGE_PIN "J17"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { led[1] }];                      # IO_L21N_T3_DQS_A18_15         Sch = led1
set_property -dict { PACKAGE_PIN "L14"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { led[2] }];                      # IO_L22P_T3_A17_15             Sch = led2
set_property -dict { PACKAGE_PIN "L15"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { led[3] }];                      # IO_L22N_T3_A16_15             Sch = led3
set_property -dict { PACKAGE_PIN "L16"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { led[4] }];                      # IO_L23P_T3_FOE_B_15           Sch = led4
set_property -dict { PACKAGE_PIN "K16"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { led[5] }];                      # IO_L23N_T3_FWE_B_15           Sch = led5
set_property -dict { PACKAGE_PIN "M15"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { led[6] }];                      # IO_L24P_T3_RS1_15             Sch = led6
set_property -dict { PACKAGE_PIN "M16"   IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { led[7] }];                      # IO_L24N_T3_RS0_15             Sch = led7


####################################################################################################################
#                                               Seven Segment                                                      #
####################################################################################################################
set_property -dict { PACKAGE_PIN "N3"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { en[0] }];                   # IO_L19N_T3_VREF_35            Sch = 7_SEG1_EN
set_property -dict { PACKAGE_PIN "R1"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { en[1] }];                   # IO_L20P_T3_35                 Sch = 7_SEG2_EN
set_property -dict { PACKAGE_PIN "P1"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { en[2] }];                   # IO_L20N_T3_35                 Sch = 7_SEG3_EN
set_property -dict { PACKAGE_PIN "L4"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { en[3] }];                   # IO_L18N_T2_35                 Sch = 7_SEG4_EN
set_property -dict { PACKAGE_PIN "P4"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { seg[0] }];            # IO_L21N_T3_DQS_35             Sch = 7SEG_0
set_property -dict { PACKAGE_PIN "N4"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { seg[1] }];            # IO_L19P_T3_35                 Sch = 7SEG_1
set_property -dict { PACKAGE_PIN "M3"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { seg[2] }];            # IO_L16P_T2_35                 Sch = 7SEG_2
set_property -dict { PACKAGE_PIN "M5"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { seg[3] }];            # IO_L23N_T3_35                 Sch = 7SEG_3
set_property -dict { PACKAGE_PIN "L5"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { seg[4] }];            # IO_L18P_T2_35                 Sch = 7SEG_4
set_property -dict { PACKAGE_PIN "L6"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { seg[5] }];            # IO_25_35                      Sch = 7SEG_5
set_property -dict { PACKAGE_PIN "M6"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { seg[6] }];            # IO_L23P_T3_35                 Sch = 7SEG_6
set_property -dict { PACKAGE_PIN "P5"    IOSTANDARD LVCMOS33    SLEW FAST} [get_ports { seg[7] }];            # IO_L21P_T3_DQS_35             Sch = 7SEG_7


####################################################################################################################
#                                               HDMI Signals                                                       #
####################################################################################################################
# HDMI_In
set_property -dict { PACKAGE_PIN "K2"    IOSTANDARD LVCMOS33 }  [get_ports { hdmi_rx_cec  }];                           # IO_L9P_T1_DQS_AD7P_35         Sch = HDMI_RX_CEC
set_property -dict { PACKAGE_PIN "J4"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_rx_clk_n}];                           # IO_L13N_T2_MRCC_35            Sch = HDMI_RX_CLK_N
set_property -dict { PACKAGE_PIN "K4"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_rx_clk_p}];                           # IO_L13P_T2_MRCC_35            Sch = HDMI_RX_CLK_P
set_property -dict { PACKAGE_PIN "G2"    IOSTANDARD LVCMOS33 }  [get_ports { hdmi_rx_hpa  }];                           # IO_L8N_T1_AD14N_35            Sch = HDMI_RX_HOT
set_property -dict { PACKAGE_PIN "J2"    IOSTANDARD LVCMOS33 }  [get_ports { hdmi_rx_scl  }];                           # IO_L9N_T1_DQS_AD7N_35         Sch = HDMI_RX_SCL                                   
set_property -dict { PACKAGE_PIN "H2"    IOSTANDARD LVCMOS33 }  [get_ports { hdmi_rx_sda  }];                           # IO_L8P_T1_AD14P_35            Sch = HDMI_RX_SDA   
set_property -dict { PACKAGE_PIN "J1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_rx_n[0] }];                           # IO_L7N_T1_AD6N_35             Sch = HDMI_RX0_N 
set_property -dict { PACKAGE_PIN "K1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_rx_p[0] }];                           # IO_L7P_T1_AD6P_35             Sch = HDMI_RX0_P  
set_property -dict { PACKAGE_PIN "L1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_rx_n[1] }];                           # IO_L15N_T2_DQS_35             Sch = HDMI_RX1_N  
set_property -dict { PACKAGE_PIN "M1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_rx_p[1] }];                           # IO_L15P_T2_DQS_35             Sch = HDMI_RX1_P  
set_property -dict { PACKAGE_PIN "N2"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_rx_n[2] }];                           # IO_L22N_T3_35                 Sch = HDMI_RX2_N  
set_property -dict { PACKAGE_PIN "P2"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_rx_p[2] }];   


##HDMI out
set_property -dict { PACKAGE_PIN "K3"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_tx_clk_n}];                           # IO_L14N_T2_SRCC_35            Sch = HDMI_TX_CLK_N 
set_property -dict { PACKAGE_PIN "L3"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_tx_clk_p}];                           # IO_L14P_T2_SRCC_35            Sch = HDMI_TX_CLK_P
#set_property -dict { PACKAGE_PIN "E2"    IOSTANDARD LVCMOS33 }  [get_ports { hdmi_tx_cec  }];                           # IO_L4P_T0_35                  Sch = HDMI_TX_CEC   
#set_property -dict { PACKAGE_PIN "B2"    IOSTANDARD LVCMOS33 }  [get_ports { hdmi_tx_hpd  }];                           # IO_L2N_T0_AD12N_35            Sch = HDMI_TX_HOT   
#set_property -dict { PACKAGE_PIN "D2"    IOSTANDARD LVCMOS33 }  [get_ports { hdmi_tx_rscl }];                           # IO_L4N_T0_35                  Sch = HDMI_TX_SCL
#set_property -dict { PACKAGE_PIN "C2"    IOSTANDARD LVCMOS33 }  [get_ports { hdmi_tx_rsda }];                           # IO_L2P_T0_AD12P_35            Sch = HDMI_TX_SDA  
set_property -dict { PACKAGE_PIN "A1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_tx_n[0] }];                           # IO_L1N_T0_AD4N_35             Sch = HDMI_TX0_N 
set_property -dict { PACKAGE_PIN "B1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_tx_p[0] }];                           # IO_L1P_T0_AD4P_35             Sch = HDMI_TX0_P  
set_property -dict { PACKAGE_PIN "D1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_tx_n[1] }];                           # IO_L3N_T0_DQS_AD5N_35         Sch = HDMI_TX1_N  
set_property -dict { PACKAGE_PIN "E1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_tx_p[1] }];                           # IO_L3P_T0_DQS_AD5P_35         Sch = HDMI_TX1_P  
set_property -dict { PACKAGE_PIN "F1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_tx_n[2] }];                           # IO_L5N_T0_AD13N_35            Sch = HDMI_TX2_N  
set_property -dict { PACKAGE_PIN "G1"    IOSTANDARD TMDS_33  }  [get_ports { hdmi_tx_p[2] }];  

####################################################################################################################
#                                          P12 Header    (Camera 1)                                                  #
####################################################################################################################
# A32 or GPIO_20_P    rdy
set_property -dict  { PACKAGE_PIN "H13"   IOSTANDARD LVCMOS33   SLEW FAST } [get_ports {C1_in[0]}];                   # IO_L1P_T0_AD0P_15             Sch = GPIO_20_P
# A31 or GPIO_19_P   trigger
set_property -dict  { PACKAGE_PIN "J14"   IOSTANDARD LVCMOS33   SLEW FAST } [get_ports {C1_out[0]}];                     # IO_L3P_T0_DQS_AD1P_15         Sch = GPIO_19_P
# A29 or GPIO_18_P  first frame
set_property -dict  { PACKAGE_PIN "M13"   IOSTANDARD LVCMOS33   SLEW FAST } [get_ports {C1_out[1]}];                      # IO_L20P_T3_A20_15             Sch = GPIO_18_P
# A28 or GPIO_17_P  hdmi switch
set_property -dict  { PACKAGE_PIN "K13"   IOSTANDARD LVCMOS33   SLEW FAST } [get_ports {C1_in[1]}];                      # IO_L19P_T3_A22_15             Sch = GPIO_17_P
####################################################################################################################
#                                          P13 Header    (Camera 2)                                                  #
####################################################################################################################
# A32 or GPIO_40_P    reserved 
set_property -dict  { PACKAGE_PIN "F16"   IOSTANDARD LVCMOS33   SLEW FAST } [get_ports {C2_in[0]}];                      # IO_L2P_T0_16                  Sch = GPIO_40_P
# A31 or GPIO_39_P    reserved 
set_property -dict  { PACKAGE_PIN "F13"   IOSTANDARD LVCMOS33   SLEW FAST } [get_ports {C2_out[0]}];                      # IO_L1P_T0_16                  Sch = GPIO_39_P
# A29 or GPIO_38_P    reserved  
set_property -dict  { PACKAGE_PIN "E13"   IOSTANDARD LVCMOS33   SLEW FAST } [get_ports {C2_out[1]}];                      # IO_L4P_T0_16                  Sch = GPIO_38_P  
# A28 or GPIO_37_P    reserved 
set_property -dict  { PACKAGE_PIN "D14"   IOSTANDARD LVCMOS33   SLEW FAST } [get_ports {C2_in[1]}];                      # IO_L6P_T0_16                  Sch = GPIO_37_P
