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
    
    input logic [5:0] A,
    input logic [5:0] B
);


logic [5:0] pc_reg;
logic soma;
logic branch_out;
logic addr_out;

assign soma = pc_reg + B;

assign branch_out = (branch?A:soma);

always_ff @(posedge clk) begin
  if (pc_enable)
    pc_reg <= branch_out;
end

assign addr_out = (addr_sel?A:pc_reg);

assign ram_addr = addr_out;

endmodule : data_path
