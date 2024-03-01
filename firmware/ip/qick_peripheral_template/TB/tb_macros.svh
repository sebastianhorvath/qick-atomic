`ifndef TB_MACROS
`define TB_MACROS

`define T_C_CLK          15 // Half Clock Period
`define T_PS_CLK         25 // Half Clock Period

`define ASSERT_EQ(VAL1, VAL2, MSG)            \
    begin                                       \
        if ((VAL1) !== (VAL2) ) begin           \
            $display("\t[FAILURE]:%s" , (MSG)); \
        end                                     \
    end #0                                      

`endif