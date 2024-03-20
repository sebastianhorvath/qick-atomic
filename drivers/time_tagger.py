from pynq.buffer import allocate
import numpy as np
from qick import DummyIp, SocIp

class  TimeTagger(SocIP):
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

        self.input_data = [attr for attr in dir(self) if 'data_reg' in attr]
        self.output_data = [attr for attr in dir(self) if 'qp_dt' in attr]

        self.cmd_val = {'arm': (1*2), 'disarm': (2*2), 'readout': (3*2)}

    #Write your functions to this module right here 
        
    def send_pulsed_cmd(self, cmd_type):
        self.control_reg = self.cmd_val[cmd_type] + 1
    
    def set_threshold(self, threshold):
        self.qp_threshold = threshold
    
    def set_delay(self, delay):
        self.qp_delay = delay
    
    def set_fraction(self, fraction):
        self.qp_fraction = fraction

    # def read_status(self):
    #     mask = 0xfff

    def read_edge(self, edge_i):
        return getattr(self, self.output_data[edge_i])
    
        
    # def const_out(self, val):
    #     #Different Controls  
    #     #self.control_reg = 1

    #     for data_reg, i in enumerate(self.input_data):
    #         setattr(self, data_reg, val*i)

