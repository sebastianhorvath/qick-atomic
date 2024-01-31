from pynq.buffer import allocate
import numpy as np
from qick import DummyIp, SocIp

class  TimeTagger(SocIP):
    bindto = ['Fermi:user:qick_peripheral:1.0']

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
                 'qp_status'  : 12, 
                 'qp_debug'   : 13}
    
    def __init__(self, description):

        super().__init__(description)

        self.input_data = [attr for attr in dir(self) if 'data_reg' in attr]
        self.output_data = [attr for attr in dir(self) if 'qp_dt' in attr]

    #Write your functions to this module right here 
    
    def const_out(self, val):
        #Different Controls  
        #self.control_reg = 1

        for data_reg, i in enumerate(self.input_data):
            setattr(self, data_reg, val*i)

