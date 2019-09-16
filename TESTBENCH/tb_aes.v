`timescale 1 ns / 10 ps

//======================================================================
//
// tb_aes.v
// --------
// Testbench for the aes top level wrapper.
//
//======================================================================


//------------------------------------------------------------------
// Test module.
//------------------------------------------------------------------
module tb_aes();

    //----------------------------------------------------------------
    // Internal constant and parameter definitions.
    //----------------------------------------------------------------
    parameter DEBUG = 0;

    parameter SCLK_HALF_PERIOD = 3;
    parameter SCLK_PERIOD = 2 * SCLK_HALF_PERIOD;

    parameter CLK_HALF_PERIOD = 7200000 * SCLK_HALF_PERIOD;

    parameter AES_128_BIT_KEY = 0;
    parameter AES_256_BIT_KEY = 1;

    parameter AES_DECIPHER = 1'b0;
    parameter AES_ENCIPHER = 1'b1;

    //----------------------------------------------------------------
    // Register and Wire declarations.
    //----------------------------------------------------------------
    reg [31 : 0] cycle_ctr;
    reg [31 : 0] error_ctr;
    reg [31 : 0] tc_ctr;

    reg [7 : 0] read_data;
    reg [7 : 0] write_data;
    reg [127 : 0] result_data;

    reg tb_sclk;
    wire tb_xout;
    reg tb_clk;
    reg tb_rst;
    wire [7 : 0] tb_data;
    wire [1 : 0] tb_pos;
    wire [6 : 0] tb_seg;
    wire tb_flag;
    wire tb_enc_dec;
    wire tb_key_len;
    wire [2 : 0] tb_phase;

    reg drive;
    assign tb_data = drive ? write_data : 8'bz;

    //----------------------------------------------------------------
    // Device Under Test.
    //----------------------------------------------------------------
    aes dut(
        .XIN(tb_sclk),
	.XOUT(tb_xout),
        .CLK(tb_clk),
        .RST(tb_rst),
        .DATA_7(tb_data[7]),
        .DATA_6(tb_data[6]),
        .DATA_5(tb_data[5]),
        .DATA_4(tb_data[4]),
        .DATA_3(tb_data[3]),
        .DATA_2(tb_data[2]),
        .DATA_1(tb_data[1]),
        .DATA_0(tb_data[0]),
        .POS_1(tb_pos[1]),
        .POS_0(tb_pos[0]),
        .SEG_6(tb_seg[6]),
        .SEG_5(tb_seg[5]),
        .SEG_4(tb_seg[4]),
        .SEG_3(tb_seg[3]),
        .SEG_2(tb_seg[2]),
        .SEG_1(tb_seg[1]),
        .SEG_0(tb_seg[0]),
        .FLAG(tb_flag),
        .ENC_DEC(tb_enc_dec),
        .KEY_LEN(tb_key_len),
        .PHASE_2(tb_phase[2]),
        .PHASE_1(tb_phase[1]),
        .PHASE_0(tb_phase[0])
    );

    //----------------------------------------------------------------
    // sclk_gen
    //
    // Always running clock generator process.
    //----------------------------------------------------------------
    always
    begin : sclk_gen
        #SCLK_HALF_PERIOD;
        tb_sclk = !tb_sclk;
    end // sclk_gen

    //----------------------------------------------------------------
    // sys_monitor()
    //
    // An always running process that creates a cycle counter and
    // conditionally displays information about the DUT.
    //----------------------------------------------------------------
    always
    begin : sys_monitor
        cycle_ctr = cycle_ctr + 1;
        #(SCLK_PERIOD);
        if (DEBUG)
        begin
            dump_dut_state();
        end
    end

    //----------------------------------------------------------------
    // dump_dut_state()
    //
    // Dump the state of the dump when needed.
    //----------------------------------------------------------------
    task dump_dut_state;
    begin
        $display("cycle: 0x%016x", cycle_ctr);
        $display("State of DUT");
        $display("------------");
//        $display("ctrl_reg:   init   = 0x%01x, next   = 0x%01x", tb_debug_init, tb_debug_next);
        $display("config_reg: encdec = 0x%01x, length = 0x%01x ", tb_enc_dec, tb_key_len);
        $display("");
//        $display("block: 0x%032x", tb_debug_block);
        $display("");
    end
    endtask // dump_dut_state

    //----------------------------------------------------------------
    // reset_dut()
    //
    // Toggle reset to put the DUT into a well known state.
    //----------------------------------------------------------------
    task reset_dut(input encdec, input key_length);
    begin
        $display("*** Toggle reset.");
        $display("Mode: encdec = 0x%01x, length = 0x%01x ", encdec, key_length);
        
        tb_rst = 0;
        #(2 * SCLK_PERIOD);

        drive = 1'b1;

        tb_rst = 1;
        #(2 * SCLK_PERIOD);

        write_byte({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, key_length, encdec});

        $display("");
    end
    endtask // reset_dut

    //----------------------------------------------------------------
    // display_test_results()
    //
    // Display the accumulated test results.
    //----------------------------------------------------------------
    task display_test_results;
    begin
        if (error_ctr == 0)
        begin
            $display("*** All %02d test cases completed successfully", tc_ctr);
        end
        else
        begin
            $display("*** %02d tests completed - %02d test cases did not complete successfully.", tc_ctr, error_ctr);
        end
    end
    endtask // display_test_results

    //----------------------------------------------------------------
    // init_sim()
    //
    // Initialize all counters and testbed functionality as well
    // as setting the DUT inputs to defined values.
    //----------------------------------------------------------------
    task init_sim;
    begin
        cycle_ctr = 0;
        error_ctr = 0;
        tc_ctr = 0;

        read_data = 8'b0;
        write_data = 8'b0;
        result_data = 127'b0;

        tb_sclk = 0;
        tb_clk = 0;
        tb_rst = 1;

        drive = 1'b0;
    end
    endtask // init_sim

    //----------------------------------------------------------------
    // write_byte()
    //
    // Write the given byte to the DUT using the DUT interface.
    //----------------------------------------------------------------
    task write_byte(input [7 : 0] byte);
    begin
        if (DEBUG)
        begin
            $display("*** Writing 0x%02x.", byte);
            $display("");
        end

        write_data = byte;
        #(2 * SCLK_PERIOD);

        tb_clk = 1;
        #(CLK_HALF_PERIOD);

        tb_clk = 0;
        #(CLK_HALF_PERIOD);

    end
    endtask // write_byte

    //----------------------------------------------------------------
    // write_block()
    //
    // Write the given block to the dut.
    //----------------------------------------------------------------
    task write_block(input [127 : 0] block);
    begin
        drive = 1'b1;
        
        write_byte(block[127 : 120]);
        write_byte(block[119 : 112]);
        write_byte(block[111 : 104]);
        write_byte(block[103 : 96]);
        write_byte(block[95 : 88]);
        write_byte(block[87 : 80]);
        write_byte(block[79 : 72]);
        write_byte(block[71 : 64]);
        write_byte(block[63 : 56]);
        write_byte(block[55 : 48]);
        write_byte(block[47 : 40]);
        write_byte(block[39 : 32]);
        write_byte(block[31 : 24]);
        write_byte(block[23 : 16]);
        write_byte(block[15 : 8]);
        write_byte(block[7 : 0]);
    end
    endtask // write_block

    //----------------------------------------------------------------
    // read_byte()
    //
    // Read a data byte from the DUT.
    // the byte read will be available in the global variable
    // read_data.
    //----------------------------------------------------------------
    task read_byte();
    begin
        tb_clk = 1;
        #(CLK_HALF_PERIOD);

        tb_clk = 0;
        #(CLK_HALF_PERIOD);

        read_data = tb_data;

        if (DEBUG)
        begin
            $display("*** Reading 0x%02x.", read_data);
            $display("");
        end
    end
    endtask // read_byte

    //----------------------------------------------------------------
    // read_result()
    //
    // Read the result block in the dut.
    //----------------------------------------------------------------
    task read_result;
    begin
        drive = 1'b0;

        read_byte();
        result_data[127 : 120] = read_data;
        read_byte();
        result_data[119 : 112] = read_data;
        read_byte();
        result_data[111 : 104] = read_data;
        read_byte();
        result_data[103 : 96] = read_data;
        read_byte();
        result_data[95 : 88] = read_data;
        read_byte();
        result_data[87 : 80] = read_data;
        read_byte();
        result_data[79 : 72] = read_data;
        read_byte();
        result_data[71 : 64] = read_data;
        read_byte();
        result_data[63 : 56] = read_data;
        read_byte();
        result_data[55 : 48] = read_data;
        read_byte();
        result_data[47 : 40] = read_data;
        read_byte();
        result_data[39 : 32] = read_data;
        read_byte();
        result_data[31 : 24] = read_data;
        read_byte();
        result_data[23 : 16] = read_data;
        read_byte();
        result_data[15 : 8] = read_data;
        read_byte();
        result_data[7 : 0] = read_data;

        tb_clk = 1;
        #(CLK_HALF_PERIOD);

        tb_clk = 0;
        #(CLK_HALF_PERIOD);
    end
    endtask // read_result

    //----------------------------------------------------------------
    // init_key()
    //
    // init the key in the dut by writing the given key and
    // key length and then trigger init processing.
    //----------------------------------------------------------------
    task init_key(input [255 : 0] key, input key_length);
    begin
        if (DEBUG)
        begin
            $display("key length: 0x%01x", key_length);
            $display("Initializing key expansion for key: 0x%016x", key);
        end

        write_byte(key[255 : 248]);
        write_byte(key[247 : 240]);
        write_byte(key[239 : 232]);
        write_byte(key[231 : 224]);
        write_byte(key[223 : 216]);
        write_byte(key[215 : 208]);
        write_byte(key[207 : 200]);
        write_byte(key[199 : 192]);
        write_byte(key[191 : 184]);
        write_byte(key[183 : 176]);
        write_byte(key[175 : 168]);
        write_byte(key[167 : 160]);
        write_byte(key[159 : 152]);
        write_byte(key[151 : 144]);
        write_byte(key[143 : 136]);
        write_byte(key[135 : 128]);

        if (key_length)
        begin
            write_byte(key[127 : 120]);
            write_byte(key[119 : 112]);
            write_byte(key[111 : 104]);
            write_byte(key[103 : 96]);
            write_byte(key[95 : 88]);
            write_byte(key[87 : 80]);
            write_byte(key[79 : 72]);
            write_byte(key[71 : 64]);
            write_byte(key[63 : 56]);
            write_byte(key[55 : 48]);
            write_byte(key[47 : 40]);
            write_byte(key[39 : 32]);
            write_byte(key[31 : 24]);
            write_byte(key[23 : 16]);
            write_byte(key[15 : 8]);
            write_byte(key[7 : 0]);
        end
        // #(100 * SCLK_PERIOD);
        wait_ready();
    end
    endtask // init_key

    //----------------------------------------------------------------
    // ecb_mode_single_block_test()
    //
    // Perform ECB mode encryption or decryption single block test.
    //----------------------------------------------------------------
    task ecb_mode_single_block_test(input [7 : 0] tc_number,
                                    input encdec,
                                    input [255 : 0] key,
                                    input key_length,
                                    input [127 : 0] block,
                                    input [127 : 0] expected);
    begin
        $display("*** TC %0d ECB mode test started.", tc_number);
        tc_ctr = tc_ctr + 1;

        reset_dut(encdec, key_length);
        init_key(key, key_length);
        
        write_block(block);
        dump_dut_state();

        // #(100 * SCLK_PERIOD);
        wait_ready();
        
        read_result();

        if (result_data == expected)
        begin
            $display("*** TC %0d successful.", tc_number);
            $display("Expected: 0x%032x", expected);
            $display("Got:      0x%032x", result_data);
            $display("");
        end
        else
        begin
            $display("*** ERROR: TC %0d NOT successful.", tc_number);
            $display("Expected: 0x%032x", expected);
            $display("Got:      0x%032x", result_data);
            $display("");
            error_ctr = error_ctr + 1;
        end
    end
    endtask // ecb_mode_single_block_test

    //----------------------------------------------------------------
    // ecb_mode_single_block_continuous_test()
    //
    // Perform ECB mode encryption or decryption single block continuous test.
    //----------------------------------------------------------------
    task ecb_mode_single_block_continuous_test(input [7 : 0] tc_number,
                                               input [127 : 0] block,
                                               input [127 : 0] expected);
    begin
        $display("*** TC %0d ECB continuous mode test started.", tc_number);
        tc_ctr = tc_ctr + 1;
        
        write_block(block);
        dump_dut_state();

        // #(100 * SCLK_PERIOD);
        wait_ready();

        read_result();

        if (result_data == expected)
        begin
            $display("*** TC %0d successful.", tc_number);
            $display("Expected: 0x%032x", expected);
            $display("Got:      0x%032x", result_data);
            $display("");
        end
        else
        begin
            $display("*** ERROR: TC %0d NOT successful.", tc_number);
            $display("Expected: 0x%032x", expected);
            $display("Got:      0x%032x", result_data);
            $display("");
            error_ctr = error_ctr + 1;
        end
    end
    endtask // ecb_mode_single_block_continuous_test

    //----------------------------------------------------------------
    // wait_ready()
    //
    // Wait for the ready flag in the dut to be set.
    //
    // Note: It is the callers responsibility to call the function
    // when the dut is actively processing and will in fact at some
    // point set the flag.
    //----------------------------------------------------------------
    task wait_ready;
    begin
        while (!tb_flag)
        begin
            #(2 * CLK_HALF_PERIOD);
        end
    end
    endtask // wait_ready

    //----------------------------------------------------------------
    // aes_test()
    //
    // Main test task will perform complete NIST test of AES.
    //----------------------------------------------------------------
    task aes_test;
    reg [255 : 0] nist_aes128_key;
    reg [255 : 0] nist_aes256_key;

    reg [127 : 0] nist_plaintext0;
    reg [127 : 0] nist_plaintext1;
    reg [127 : 0] nist_plaintext2;
    reg [127 : 0] nist_plaintext3;

    reg [127 : 0] nist_ecb_128_enc_expected0;
    reg [127 : 0] nist_ecb_128_enc_expected1;
    reg [127 : 0] nist_ecb_128_enc_expected2;
    reg [127 : 0] nist_ecb_128_enc_expected3;

    reg [127 : 0] nist_ecb_256_enc_expected0;
    reg [127 : 0] nist_ecb_256_enc_expected1;
    reg [127 : 0] nist_ecb_256_enc_expected2;
    reg [127 : 0] nist_ecb_256_enc_expected3;

    begin
        nist_aes128_key = 256'h2b7e151628aed2a6abf7158809cf4f3c00000000000000000000000000000000;
        nist_aes256_key = 256'h603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4;

        nist_plaintext0 = 128'h6bc1bee22e409f96e93d7e117393172a;
        nist_plaintext1 = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
        nist_plaintext2 = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
        nist_plaintext3 = 128'hf69f2445df4f9b17ad2b417be66c3710;

        nist_ecb_128_enc_expected0 = 128'h3ad77bb40d7a3660a89ecaf32466ef97;
        nist_ecb_128_enc_expected1 = 128'hf5d3d58503b9699de785895a96fdbaaf;
        nist_ecb_128_enc_expected2 = 128'h43b1cd7f598ece23881b00e3ed030688;
        nist_ecb_128_enc_expected3 = 128'h7b0c785e27e8ad3f8223207104725dd4;

        nist_ecb_256_enc_expected0 = 128'hf3eed1bdb5d2a03c064b5a7e3db181f8;
        nist_ecb_256_enc_expected1 = 128'h591ccb10d410ed26dc5ba74a31362870;
        nist_ecb_256_enc_expected2 = 128'hb6ed21b99ca6f4f9f153e7b1beafed1d;
        nist_ecb_256_enc_expected3 = 128'h23304b7a39f9f3ff067d8d8f9e24ecc7;


        $display("ECB 128 bit key single encryption tests");
        $display("---------------------");
        ecb_mode_single_block_test(8'h01, AES_ENCIPHER, nist_aes128_key, AES_128_BIT_KEY,
                                   nist_plaintext0, nist_ecb_128_enc_expected0);
        ecb_mode_single_block_test(8'h02, AES_ENCIPHER, nist_aes128_key, AES_128_BIT_KEY,
                                   nist_plaintext1, nist_ecb_128_enc_expected1);
        ecb_mode_single_block_test(8'h03, AES_ENCIPHER, nist_aes128_key, AES_128_BIT_KEY,
                                   nist_plaintext2, nist_ecb_128_enc_expected2);
        ecb_mode_single_block_test(8'h04, AES_ENCIPHER, nist_aes128_key, AES_128_BIT_KEY,
                                   nist_plaintext3, nist_ecb_128_enc_expected3);
        $display("");
        $display("ECB 128 bit key continuous encryption tests");
        $display("---------------------");
        ecb_mode_single_block_continuous_test(8'h05, nist_plaintext0, nist_ecb_128_enc_expected0);
        ecb_mode_single_block_continuous_test(8'h06, nist_plaintext1, nist_ecb_128_enc_expected1);
        ecb_mode_single_block_continuous_test(8'h07, nist_plaintext2, nist_ecb_128_enc_expected2);
        ecb_mode_single_block_continuous_test(8'h08, nist_plaintext3, nist_ecb_128_enc_expected3);
        $display("");
        $display("ECB 128 bit key single decryption tests");
        $display("---------------------");
        ecb_mode_single_block_test(8'h09, AES_DECIPHER, nist_aes128_key, AES_128_BIT_KEY,
                                   nist_ecb_128_enc_expected0, nist_plaintext0);
        ecb_mode_single_block_test(8'h0a, AES_DECIPHER, nist_aes128_key, AES_128_BIT_KEY,
                                   nist_ecb_128_enc_expected1, nist_plaintext1);
        ecb_mode_single_block_test(8'h0b, AES_DECIPHER, nist_aes128_key, AES_128_BIT_KEY,
                                   nist_ecb_128_enc_expected2, nist_plaintext2);
        ecb_mode_single_block_test(8'h0c, AES_DECIPHER, nist_aes128_key, AES_128_BIT_KEY,
                                   nist_ecb_128_enc_expected3, nist_plaintext3);
        $display("");
        $display("ECB 128 bit key continuous decryption tests");
        $display("---------------------");
        ecb_mode_single_block_continuous_test(8'h0d, nist_ecb_128_enc_expected0, nist_plaintext0);
        ecb_mode_single_block_continuous_test(8'h0e, nist_ecb_128_enc_expected1, nist_plaintext1);
        ecb_mode_single_block_continuous_test(8'h0f, nist_ecb_128_enc_expected2, nist_plaintext2);
        ecb_mode_single_block_continuous_test(8'h10, nist_ecb_128_enc_expected3, nist_plaintext3);
        $display("");
        $display("ECB 256 bit key single encryption tests");
        $display("---------------------");
        ecb_mode_single_block_test(8'h11, AES_ENCIPHER, nist_aes256_key, AES_256_BIT_KEY,
                                   nist_plaintext0, nist_ecb_256_enc_expected0);
        ecb_mode_single_block_test(8'h12, AES_ENCIPHER, nist_aes256_key, AES_256_BIT_KEY,
                                   nist_plaintext1, nist_ecb_256_enc_expected1);
        ecb_mode_single_block_test(8'h13, AES_ENCIPHER, nist_aes256_key, AES_256_BIT_KEY,
                                   nist_plaintext2, nist_ecb_256_enc_expected2);
        ecb_mode_single_block_test(8'h14, AES_ENCIPHER, nist_aes256_key, AES_256_BIT_KEY,
                                   nist_plaintext3, nist_ecb_256_enc_expected3);
        $display("");
        $display("ECB 256 bit key continuous encryption tests");
        $display("---------------------");
        ecb_mode_single_block_continuous_test(8'h15, nist_plaintext0, nist_ecb_256_enc_expected0);
        ecb_mode_single_block_continuous_test(8'h16, nist_plaintext1, nist_ecb_256_enc_expected1);
        ecb_mode_single_block_continuous_test(8'h17, nist_plaintext2, nist_ecb_256_enc_expected2);
        ecb_mode_single_block_continuous_test(8'h18, nist_plaintext3, nist_ecb_256_enc_expected3);
        $display("");
        $display("ECB 256 bit key single decryption tests");
        $display("---------------------");
        ecb_mode_single_block_test(8'h19, AES_DECIPHER, nist_aes256_key, AES_256_BIT_KEY,
                                   nist_ecb_256_enc_expected0, nist_plaintext0);
        ecb_mode_single_block_test(8'h1a, AES_DECIPHER, nist_aes256_key, AES_256_BIT_KEY,
                                   nist_ecb_256_enc_expected1, nist_plaintext1);
        ecb_mode_single_block_test(8'h1b, AES_DECIPHER, nist_aes256_key, AES_256_BIT_KEY,
                                   nist_ecb_256_enc_expected2, nist_plaintext2);
        ecb_mode_single_block_test(8'h1c, AES_DECIPHER, nist_aes256_key, AES_256_BIT_KEY,
                                   nist_ecb_256_enc_expected3, nist_plaintext3);
        $display("");
        $display("ECB 256 bit key continuous decryption tests");
        $display("---------------------");
        ecb_mode_single_block_continuous_test(8'h1d, nist_ecb_256_enc_expected0, nist_plaintext0);
        ecb_mode_single_block_continuous_test(8'h1e, nist_ecb_256_enc_expected1, nist_plaintext1);
        ecb_mode_single_block_continuous_test(8'h1f, nist_ecb_256_enc_expected2, nist_plaintext2);
        ecb_mode_single_block_continuous_test(8'h20, nist_ecb_256_enc_expected3, nist_plaintext3);
    end
    endtask // aes_test

    //----------------------------------------------------------------
    // main
    //
    // The main test functionality.
    //----------------------------------------------------------------
    initial
    begin : main
        $sdf_annotate("post.sdf", aes, , ,"MINIMUM");
        $display("   -= Testbench for AES started =-");
        $display("    ==============================");
        $display("");

        init_sim();
        dump_dut_state();
        reset_dut(AES_ENCIPHER, AES_256_BIT_KEY);
        dump_dut_state();

        aes_test();

        display_test_results();

        $display("");
        $display("*** AES simulation done. ***");
        $finish;
    end // main
    endmodule // tb_aes

//======================================================================
// EOF tb_aes.v
//======================================================================
