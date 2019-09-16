`timescale 1 ns / 10 ps

module aes(
    input XIN,
    output XOUT,
    input CLK,
    input RST,
    inout DATA_7,
    inout DATA_6,
    inout DATA_5,
    inout DATA_4,
    inout DATA_3,
    inout DATA_2,
    inout DATA_1,
    inout DATA_0,
    output POS_1,
    output POS_0,
    output SEG_6,
    output SEG_5,
    output SEG_4,
    output SEG_3,
    output SEG_2,
    output SEG_1,
    output SEG_0,
    output FLAG,
    output ENC_DEC,
    output KEY_LEN,
    output PHASE_2,
    output PHASE_1,
    output PHASE_0
);

wire sysclock;
wire clock;
wire reset;
wire [7 : 0] data;
wire [1 : 0] pos;
wire [6 : 0] seg;
wire [2 : 0] phase;

reg encdec;
reg init;
reg next;
wire ready;
reg [255 : 0] key;
reg keylen;
reg [127 : 0] block;
wire [127 : 0] result;
wire result_valid;
reg [7 : 0] result_reg;
reg [4 : 0] cnt_32;

reg drive;
reg [2 : 0] current_status;
reg [2 : 0] next_status;

wire [7 : 0] display_data;

// XIN, XOUT
PX3W SCLK_PAD (
    .XIN(XIN),
    .XOUT(XOUT),
    .XC(sysclock)
);

// CLK
PIDW CLK_PAD (
    .PAD(CLK),
    .C(clock)
);

// RST
PIUW RST_PAD (
    .PAD(RST),
    .C(reset)
);

// DATA_7
PBD20W DATA_7_PAD (
    .PAD(DATA_7),
    .OEN(~drive),
    .I(result_reg[7]),
    .C(data[7])
);

// DATA_6
PBD20W DATA_6_PAD (
    .PAD(DATA_6),
    .OEN(~drive),
    .I(result_reg[6]),
    .C(data[6])
);

// DATA_5
PBD20W DATA_5_PAD (
    .PAD(DATA_5),
    .OEN(~drive),
    .I(result_reg[5]),
    .C(data[5])
);

// DATA_4
PBD20W DATA_4_PAD (
    .PAD(DATA_4),
    .OEN(~drive),
    .I(result_reg[4]),
    .C(data[4])
);

// DATA_3
PBD20W DATA_3_PAD (
    .PAD(DATA_3),
    .OEN(~drive),
    .I(result_reg[3]),
    .C(data[3])
);

// DATA_2
PBD20W DATA_2_PAD (
    .PAD(DATA_2),
    .OEN(~drive),
    .I(result_reg[2]),
    .C(data[2])
);

// DATA_1
PBD20W DATA_1_PAD (
    .PAD(DATA_1),
    .OEN(~drive),
    .I(result_reg[1]),
    .C(data[1])
);

// DATA_0
PBD20W DATA_0_PAD (
    .PAD(DATA_0),
    .OEN(~drive),
    .I(result_reg[0]),
    .C(data[0])
);

// POS_1
PO20W POS_1_PAD (
    .PAD(POS_1),
    .I(pos[1])
);

// POS_0
PO20W POS_0_PAD (
    .PAD(POS_0),
    .I(pos[0])
);

// SEG_6
PO20W SEG_6_PAD (
    .PAD(SEG_6),
    .I(seg[6])
);

// SEG_5
PO20W SEG_5_PAD (
    .PAD(SEG_5),
    .I(seg[5])
);

// SEG_4
PO20W SEG_4_PAD (
    .PAD(SEG_4),
    .I(seg[4])
);

// SEG_3
PO20W SEG_3_PAD (
    .PAD(SEG_3),
    .I(seg[3])
);

// SEG_2
PO20W SEG_2_PAD (
    .PAD(SEG_2),
    .I(seg[2])
);

// SEG_1
PO20W SEG_1_PAD (
    .PAD(SEG_1),
    .I(seg[1])
);

// SEG_0
PO20W SEG_0_PAD (
    .PAD(SEG_0),
    .I(seg[0])
);

// FLAG
PO20W FLAG_PAD (
    .PAD(FLAG),
    .I(ready | result_valid)
);

// ENC_DEC
PO20W ENC_DEC_PAD (
    .PAD(ENC_DEC),
    .I(encdec)
);

// KEY_LEN
PO20W KEY_LEN_PAD (
    .PAD(KEY_LEN),
    .I(keylen)
);

// PHASE_2
PO20W PHASE_2_PAD (
    .PAD(PHASE_2),
    .I(phase[2])
);

// PHASE_1
PO20W PHASE_1_PAD (
    .PAD(PHASE_1),
    .I(phase[1])
);

// PHASE_0
PO20W PHASE_0_PAD (
    .PAD(PHASE_0),
    .I(phase[0])
);

// assign data = drive ? result_reg : 8'bz;
assign phase = current_status;

assign display_data = drive ? result_reg : data;

parameter FSM_INIT = 3'b000;
parameter FSM_KEY = 3'b001;
parameter FSM_INPUT = 3'b011;
parameter FSM_OUTPUT = 3'b010;
parameter FSM_SWITCH = 3'b110;

aes_core aes_core(
    .clk(sysclock),
    .reset_n(reset),
    .encdec(encdec),
    .init(init),
    .next(next),
    .ready(ready),
    .key(key),
    .keylen(keylen),
    .block(block),
    .result(result),
    .result_valid(result_valid)
);

display display(
    .clk(sysclock),
    .rst(reset),
    .data_in(display_data),
    .sel(pos),
    .data_out(seg)
);

always @(posedge sysclock or negedge reset)
begin
    if (!reset)
    begin
        current_status <= FSM_INIT;
        init <= 1'b0;
        next <= 1'b0;
    end
    else
    begin
        current_status <= next_status;
        init <= (current_status == FSM_KEY & next_status == FSM_INPUT);
        next <= (current_status == FSM_INPUT & next_status == FSM_OUTPUT);
    end
end

always @(posedge clock or negedge reset)
begin
    if (!reset)
    begin
        drive <= 1'b0;
        encdec <= 1'b0;
        key <= 256'b0;
        keylen <= 1'b0;
        block <= 128'b0;
        result_reg <= 7'b0;
        cnt_32 <= 5'b0;
        next_status <= FSM_INIT;
    end
    else if (current_status == next_status)
    begin
        case (current_status)
        FSM_INIT:
        begin
            encdec <= data[0];
            keylen <= data[1];
            next_status <= FSM_KEY;
        end

        FSM_KEY:
        begin
            key[255 - (cnt_32 * 8) -: 8] <= data;
            if (cnt_32 < (keylen ? 5'b11111 : 5'b01111))
                cnt_32 <= cnt_32 + 1;
            else
            begin
                cnt_32 <= 5'b0;
                next_status <= FSM_INPUT;
            end
        end

        FSM_INPUT:
        begin
            block[127 - (cnt_32 * 8) -: 8] <= data;
            if (cnt_32 < 5'b01111)
                cnt_32 <= cnt_32 + 1;
            else
            begin
                cnt_32 <= 5'b0;
                next_status <= FSM_OUTPUT;
            end
        end

        FSM_OUTPUT:
        begin
            drive <= 1'b1;
            result_reg <= result[127 - (cnt_32 * 8) -: 8];
            if (cnt_32 < 5'b01111)
                cnt_32 <= cnt_32 + 1;
            else
            begin
                cnt_32 <= 5'b0;
                next_status <= FSM_SWITCH;
            end
        end

        FSM_SWITCH:
        begin
            drive <= 1'b0;
            result_reg <= 8'b0;
            next_status <= FSM_INPUT;
        end

        default:
        begin
            drive <= 1'b0;
            encdec <= 1'b0;
            key <= 256'b0;
            keylen <= 1'b0;
            block <= 128'b0;
            result_reg <= 7'b0;
            cnt_32 <= 5'b0;
            next_status <= FSM_INIT;
        end
        endcase
    end
end
endmodule
