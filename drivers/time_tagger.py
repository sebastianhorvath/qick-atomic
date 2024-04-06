from pynq.buffer import allocate
import numpy as np
from qick import DummyIp, SocIp

class TimeTagger(SocIp):
    bindto = ['Fermi:user:qick_time_tagger_HS:1.0']

    REGISTERS = {'control_reg': 0,
                 'config_reg' : 1,
                 'data_reg_1' : 2,
                 'data_reg_2' : 3,
                 'data_reg_3' : 4,
                 'data_reg_4' : 5, 
                 'qp_dt1'     : 7,
                 'qp_dt2'     : 8, 
                 'qp_dt3'     : 9,
                 'qp_dt4'     : 10,
                 'qp_delay'   : 11,
                 'qp_fraction': 12,
                 'qp_threshold':13,
                 'qp_status'  : 14, 
                 'qp_debug'   : 15}
    
    def __init__(self, description):

        super().__init__(description)

        self.input_data = [key for key in self.REGISTERS if 'data_reg' in key]
        self.output_data = [key for key in self.REGISTERS if 'qp_dt' in key]

        self.cmd_val = {'arm': (1*2), 'disarm': (2*2), 'readout': (3*2)}

        #default values
        self.qp_threshold = 2**12
        
        self.FIFO_W = int(description['parameters']['FIFO_W'])
        

    #Write your functions to this module right here 
    def configure_axi(self, on):
        if on is True :
            self.config_reg = 1 << 7
        else:
            self.config_reg = 0 << 7

    def read_cfg(self):
        return self.config_reg

    def read_threshold(self):
        return self.qp_threshold

    def send_pulsed_cmd(self, cmd_type):
        self.control_reg = self.cmd_val[cmd_type] + 1
    
    def set_threshold(self, threshold):
        self.qp_threshold = threshold
    
    def set_delay(self, delay):
        self.qp_delay = delay
    
    def set_fraction(self, fraction):
        self.qp_fraction = fraction
    
    def read_status(self):
        fifo_cnt_mask = (1 << self.FIFO_W) - 1
        fifo_cnt = fifo_cnt_mask & self.qp_status
        err_msg = self.qp_status >> self.FIFO_W
        return err_msg, fifo_cnt

    def read_edge(self, edge_i):
        if self.read_status()[1] == 0:
           print("Empty Fifo cannot read")
           return 0
        return getattr(self, self.output_data[edge_i])