module data_path
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    input  logic                    branch,
    input  logic                    pc_enable,
    input  logic                    ir_enable,
    input  logic                    addr_sel,
    input  logic                    c_sel,
    input  logic              [1:0] operation,
    input  logic                    write_reg_enable,
    input  logic                    flags_reg_enable,
    output decoded_instruction_type decoded_instruction,
    output logic                    zero_op,
    output logic                    neg_op,
    output logic                    unsigned_overflow,
    output logic                    signed_overflow,
    output logic              [4:0] ram_addr,
    output logic             [15:0] data_out,
    input  logic             [15:0] data_in
);

logic [4:0]  program_counter;
logic [15:0] instruction;
logic [1:0]  a_addr;
logic [1:0]  b_addr;
logic [1:0]  c_addr;
logic [4:0]  mem_addr;
logic [15:0] bus_a;
logic [15:0] bus_b;
logic [15:0] bus_c;
logic [15:0] bus_a_complemento;
logic [15:0] alu_out;
logic        flag_zero;
logic        flag_neg;
logic        flag_unsigned_overflow;
logic        flag_signed_overflow;
logic        carry_in_ultimo_bit;

always_ff @(posedge clk) begin
    if (ir_enable)
        instruction <= data_in;
end

always_comb begin : decoder
    a_addr = 'd0;
    b_addr = 'd0;
    c_addr = 'd0;
    mem_addr = 'd0;

    case(instruction[15:8])
        8'b1000_0001: begin
            decoded_instruction = I_LOAD;
            c_addr = instruction[6:5];
            mem_addr = instruction[4:0];
        end

        8'b1000_0010: begin
            decoded_instruction = I_STORE;
            a_addr = instruction[6:5];
            mem_addr = instruction[4:0];
        end

        8'b1001_0001: begin
            decoded_instruction = I_MOVE;
            a_addr = instruction[1:0];
            b_addr = instruction[1:0];
            c_addr = instruction[3:2];
        end

        8'b1010_0001: begin
            decoded_instruction = I_ADD;
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end

        8'b1010_0010: begin
            decoded_instruction = I_SUB;
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end

        8'b1010_0011: begin
            decoded_instruction = I_AND;
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end

        8'b1010_0100: begin
            decoded_instruction = I_OR;
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end

        8'b0000_0001: begin
            decoded_instruction = I_BRANCH;
            mem_addr = instruction[4:0];
        end

        8'b0000_0010: begin
            decoded_instruction = I_BZERO;
            mem_addr = instruction[4:0];
        end

        8'b0000_0011: begin
            decoded_instruction = I_BNEG;
            mem_addr = instruction[4:0];
        end

        8'b0000_0101: begin
            decoded_instruction = I_BOV;
            mem_addr = instruction[4:0];
        end

        8'b0000_0110: begin
            decoded_instruction = I_BNOV;
            mem_addr = instruction[4:0];
        end

        8'b0000_1010: begin
            decoded_instruction = I_BNNEG;
            mem_addr = instruction[4:0];
        end

        8'b0000_1011: begin
            decoded_instruction = I_BNZERO;
            mem_addr = instruction[4:0];
        end

        8'b1111_1111: begin
            decoded_instruction = I_HALT;
        end

        8'b0000_0000: begin
            decoded_instruction = I_NOP;
        end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin : pc_ctrl // FF program_counter
    if (!rst_n) begin
        program_counter <= 'd0;
    end
    else if (pc_enable) begin
        if (branch)
            program_counter <= mem_addr;
        else
            program_counter <= program_counter + 1;
    end
end

always_comb begin : addr_out
    if (addr_sel)
        ram_addr = mem_addr; 
    else
        ram_addr = program_counter;
end

always_comb begin : bus_c_out
    if (c_sel)
        bus_c = alu_out;
    else
        bus_c = data_in;
end

// Banco de Registradores
logic [15:0] r [4] = '{ default: 8'd87}; 

always_ff @(posedge clk) begin 
    if(!rst_n) begin
        r[0] = 15'b000000000000000;
        r[1] = 15'b000000000000000;
        r[2] = 15'b000000000000000;
        r[3] = 15'b000000000000000;
    end

    if (write_reg_enable) begin
        case (a_addr)
            2'b00: begin
                bus_a = r[0];
            end

            2'b01: begin
                bus_a = r[1];
            end

            2'b10: begin
                bus_a = r[2];
            end

            2'b11: begin
                bus_a = r[3];
            end
        endcase

        case (b_addr)
            2'b00: begin
                bus_b = r[0];
            end

            2'b01: begin
                bus_b = r[1];
            end

            2'b10: begin
                bus_b = r[2];
            end

            2'b11: begin
                bus_b = r[3];
            end
        endcase

        case (c_addr)
            2'b00: begin
                r[0] = bus_c;
            end

            2'b01: begin
                r[1] = bus_c;
            end

            2'b10: begin
                r[2] = bus_c;
            end

            2'b11: begin
                r[3] = bus_c;
            end
        endcase
    end
end

assign data_out = bus_a;

always_comb begin : ula_ctrl
    case(operation)
        2'b00:  begin // OR
            alu_out = bus_a | bus_b;
            flag_signed_overflow = 1'b0;
            flag_unsigned_overflow = 1'b0;
            carry_in_ultimo_bit = 1'b0;
        end

        2'b01: begin // ADD
            {carry_in_ultimo_bit, alu_out[14:0]} = bus_a[14:0] + bus_b[14:0];
            {flag_unsigned_overflow, alu_out[15]} = bus_a[15] + bus_b[15] + carry_in_ultimo_bit;
            flag_signed_overflow = flag_unsigned_overflow ^ carry_in_ultimo_bit;
        end

        2'b10: begin // SUB
            bus_a_complemento = (~bus_a) + 1;
            {carry_in_ultimo_bit, alu_out[14:0]} = bus_a_complemento[14:0] + bus_b[14:0];
            {flag_unsigned_overflow, alu_out[15]} = bus_a_complemento[15] + bus_b[15] + carry_in_ultimo_bit;
            flag_signed_overflow = flag_unsigned_overflow ^ carry_in_ultimo_bit;
        end

        default: begin // AND
            alu_out = bus_a & bus_b;
            flag_signed_overflow = 1'b0;
            flag_unsigned_overflow = 1'b0;
            carry_in_ultimo_bit = 1'b0;
        end
    endcase
end

assign flag_neg = alu_out[15];
assign flag_zero = ~|(alu_out);
  
always_ff @(posedge clk) begin
    if (flags_reg_enable) begin
        zero_op <= flag_zero;
        neg_op <= flag_neg;
        unsigned_overflow <= flag_unsigned_overflow;
        signed_overflow <= flag_signed_overflow;
    end
end

endmodule : data_path