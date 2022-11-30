//control unit
module control_unit
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    output logic                    branch,
    output logic                    pc_enable,
    output logic                    ir_enable,
    output logic                    write_reg_enable,
    output logic                    addr_sel,
    output logic                    c_sel,
    output logic              [1:0] operation,
    output logic                    flags_reg_enable,
    input  decoded_instruction_type decoded_instruction,
    input  logic                    zero_op,
    input  logic                    neg_op,
    input  logic                    unsigned_overflow,
    input  logic                    signed_overflow,
    output logic                    ram_write_enable,
    output logic                    halt
);

typedef enum {
    BUSCA_INSTR,
    REG_INSTR,
    DECODIFICA,
    LOAD_RAM,
    ALU_CALC,
    STORE_RAM,
    BRANCH,
    FIM_PROGRAMA
} state_t;

state_t state;
state_t next_state;

always_ff @(posedge clk or negedge rst_n) begin : mem_fsm
    if(!rst_n)
        state <= BUSCA_INSTR;
    else
        state <= next_state;
end

always_comb begin : calc_next_state
    // valores default
    branch = 1'b0;
    pc_enable = 1'b0;
    ir_enable = 1'b0;
    write_reg_enable = 1'b0;
    addr_sel = 1'b0;
    c_sel = 1'b0;
    operation = 2'b00;
    flags_reg_enable = 1'b0;
    ram_write_enable = 1'b0;
    halt = 1'b0;

    case(state)
        BUSCA_INSTR : begin
            next_state = REG_INSTR;
        end

        REG_INSTR : begin
            next_state = DECODIFICA;
            ir_enable = 1'b1;
            pc_enable = 1'b1;
        end

        DECODIFICA : begin 
            next_state = BUSCA_INSTR;

            case (decoded_instruction)
                I_HALT : begin
                    next_state = FIM_PROGRAMA;
                end

                I_LOAD : begin
                    next_state = LOAD_RAM;
                    addr_sel = 1'b1;
                end

                I_OR : begin
                    next_state = ALU_CALC;
                    operation = 2'b00;
                    flags_reg_enable = 1'b1;
                end

                I_ADD : begin
                    next_state = ALU_CALC;
                    operation = 2'b01;
                    flags_reg_enable = 1'b1;
                end

                I_SUB : begin
                    next_state = ALU_CALC;
                    operation = 2'b10;
                    flags_reg_enable = 1'b1;
                end

                I_AND : begin
                    next_state = ALU_CALC;
                    operation = 2'b11;
                    flags_reg_enable = 1'b1;
                end

                I_MOVE : begin
                    next_state = ALU_CALC;
                    operation = 2'b00;
                    flags_reg_enable = 1'b0;
                end

                I_STORE : begin
                    next_state = STORE_RAM;
                    addr_sel = 1'b1;
                end

                I_BRANCH : begin
                    next_state = BRANCH;
                end

                I_BZERO : begin
                    next_state = BUSCA_INSTR;
                    if (zero_op)
                        next_state = BRANCH;  
                end

                I_BNZERO : begin 
                    next_state = BUSCA_INSTR;
                    if (!zero_op)
                        next_state = BRANCH; 
                end

                I_BNEG : begin
                    next_state = BUSCA_INSTR;
                    if(neg_op)
                        next_state = BRANCH;
                end

                I_BNNEG : begin
                    next_state = BUSCA_INSTR;
                    if(!neg_op)
                        next_state = BRANCH;
                end

                I_BOV : begin
                    next_state = BUSCA_INSTR;
                    if(unsigned_overflow)
                        next_state = BRANCH;
                end

                I_BNOV : begin
                    next_state = BUSCA_INSTR;
                    if(!unsigned_overflow)
                        next_state = BRANCH;  
                end
            endcase
        end

        BRANCH : begin
            next_state = BUSCA_INSTR;
            pc_enable = 1'b1;
            branch = 1'b1;
            addr_sel = 1'b1;
        end 

        LOAD_RAM : begin
            next_state = BUSCA_INSTR;
            write_reg_enable = 1'b1;
            addr_sel = 1'b1;
        end

        ALU_CALC : begin
            next_state = BUSCA_INSTR;
            ir_enable = 1'b1;
            c_sel = 1'b1;
            write_reg_enable = 1'b1;
        end

        STORE_RAM : begin
            next_state = BUSCA_INSTR;
            ram_write_enable = 1'b1;
            addr_sel = 1'b1;
            write_reg_enable = 1'b1;
        end

        FIM_PROGRAMA : begin
            next_state = FIM_PROGRAMA;
            halt = 1'b1;
        end
    endcase
end

endmodule : control_unit