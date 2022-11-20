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
   
    output logic       cy,
    input  logic       ldR_out
);

logic [4:0] pc_reg;
logic [15:0] ir_reg;
logic sum;
logic branch_out;
logic addr_out;
logic [1:0] a_addr;
logic [1:0] b_addr;
logic [1:0] c_addr;
logic [4:0] mem_addr;
logic [15:0] bus_a;
logic [15:0] bus_b;
logic [15:0] bus_c;

always_ff @(posedge clk) begin
  if (ir_enable)
    ir_reg <= data_in;
end

always_comb begin : decoder
  a_addr = 'd0;
  b_addr = 'd0;
  c_addr = 'd0;
  mem_addr = 'd0;

  case(ir_reg[15:8])
    8'b1000_0001: begin
      decoded_instruction = I_LOAD;
      c_addr = ir_reg[6:5];
      mem_addr = ir_reg[4:0];
    end

    8'b1000_0010: begin
      decoded_instruction = I_LOAD;
      a_addr = ir_reg[6:5];
      mem_addr = ir_reg[4:0];
    end

    8'b1001_0001: begin
      decoded_instruction = I_MOVE;
      a_addr = ir_reg[1:0];
      b_addr = ir_reg[1:0];
      c_addr = ir_reg[3:2];
    end

    8'b1010_0001: begin
      decoded_instruction = I_ADD;
      a_addr = ir_reg[1:0];
      b_addr = ir_reg[3:2];
      c_addr = ir_reg[5:4];
    end

    8'b1010_0010: begin
      decoded_instruction = I_SUB;
      a_addr = ir_reg[1:0];
      b_addr = ir_reg[3:2];
      c_addr = ir_reg[5:4];
    end

    8'b1010_0011: begin
      decoded_instruction = I_AND;
      a_addr = ir_reg[1:0];
      b_addr = ir_reg[3:2];
      c_addr = ir_reg[5:4];
    end

    8'b1010_0100: begin
      decoded_instruction = I_OR;
      a_addr = ir_reg[1:0];
      b_addr = ir_reg[3:2];
      c_addr = ir_reg[5:4];
    end

    8'b0000_0001: begin
      decoded_instruction = I_BRANCH;
      mem_addr = ir_reg[4:0];
    end

    8'b0000_0010: begin
      decoded_instruction = I_BZERO;
      mem_addr = ir_reg[4:0];
    end

    8'b0000_0011: begin
      decoded_instruction = I_BNEG;
      mem_addr = ir_reg[4:0];
    end

    8'b0000_0000: begin
      decoded_instruction = I_NOP;
    end

    8'b1111_1111: begin
      decoded_instruction = I_HALT;
    end
  endcase
end

always_ff @(posedge clk) begin // FF calcula program_counter
  if (pc_enable) begin
    if (branch)
        pc_reg <= mem_addr;
    else
        pc_reg <= pc_reg + 1;
    end
end

assign addr_out = (addr_sel?mem_addr:pc_reg);

assign ram_addr = addr_out;

// Banco de Registradores
logic [15:0] rf [3] = '{ default: 8'd87};

always_ff @(posedge clk) begin
  if (write_reg_enable)
    rf[bus_a] <= a_addr;
    rf[bus_b] <= b_addr;
    rf[bus_c] <= c_addr;
end


endmodule : data_path
