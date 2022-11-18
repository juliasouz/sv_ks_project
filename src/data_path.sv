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
    input  logic             [15:0] data_in,
   
    input logic [4:0] B
);


logic [4:0] pc_reg;
logic [15:0] ir_reg;
logic sum;
logic branch_out;
logic addr_out;
logic [4:0] a_addr;
logic [4:0] b_addr;
logic [4:0] c_addr;
logic [4:0] mem_addr;

// Decode - Verificar como fazer
always_comb begin
  case(ir_reg)
    3'b100: a_addr = 4'b1110;
    3'b101: b_addr = 4'b1110;
    3'b110: c_addr = 4'b1110;
    3'b111: mem_addr = 4'b1110;
    default: decoded_instruction[0] = 4'b0000;
  endcase
end

// Soma com PC_REG com B - Verificar o que é B
assign sum = pc_reg + B;

assign branch_out = (branch?mem_addr:sum);

always_ff @(posedge clk) begin
  if (pc_enable)
    pc_reg <= branch_out;
end

assign addr_out = (addr_sel?mem_addr:pc_reg);

assign ram_addr = addr_out;

always_ff @(posedge clk) begin
  if (ir_enable)
    ir_reg <= data_in;
end

// Banco de registradores - Verificar default para 2 bits
logic [4:0] rf [4] = '{ default: 8'd87};

    // Paramos aqui

endmodule : data_path