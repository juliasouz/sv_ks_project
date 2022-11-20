package k_and_s_pkg;
  typedef enum  logic [15:0] {
    I_NOP =    16'b0000_0000_0000_0001,
    I_LOAD =   16'b0000_0000_0000_0010,
    I_STORE =  16'b0000_0000_0000_0100,
    I_MOVE =   16'b0000_0000_0000_1000,
    I_ADD =    16'b0000_0000_0001_0000,
    I_SUB =    16'b0000_0000_0010_0000,
    I_AND =    16'b0000_0000_0100_0000,
    I_OR =     16'b0000_0000_1000_0000,
    I_BRANCH = 16'b0000_0001_0000_0000,
    I_BZERO =  16'b0000_0010_0000_0000,
    I_BNZERO = 16'b0000_0100_0000_0000,
    I_BNEG =   16'b0000_1000_0000_0000,
    I_BNNEG =  16'b0001_0000_0000_0000,
    I_HALT =   16'b0010_0000_0000_0000,
    I_BOV =    16'b0100_0000_0000_0000,
    I_BNOV =   16'b1000_0000_0000_0000
} decoded_instruction_type;  // Decoded instruction in decode

endpackage : k_and_s_pkg

