library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_Debayering_Filter is
end tb_Debayering_Filter;

architecture sim of tb_Debayering_Filter is

    -- Constants
    constant CLK_PERIOD : time := 10 ns;

    -- We replace static constants with variables inside the process
    -- to handle dynamic sizing.

    -- Signals
    signal clk            : std_logic := '0';
    signal rst_n          : std_logic := '0';
    signal new_image      : std_logic := '0';
    signal valid_in       : std_logic := '0';
    signal pixel          : std_logic_vector(7 downto 0) := (others => '0');
    
    -- New Signals for Dynamic Sizing
    signal image_dim      : std_logic_vector(10 downto 0) := (others => '0');
    signal image_dim_vld  : std_logic := '0';
    
    signal image_finished : std_logic;
    signal valid_out      : std_logic;
    signal R, G, B        : std_logic_vector(7 downto 0);
    
    signal sim_done       : boolean := false;
 
begin

    -- 1. DUT Instantiate (Removed the generic map)
    uut: entity work.Debayering_Filter
        port map (
            clk => clk, 
            rst_n => rst_n, 
            new_image => new_image,
            valid_in => valid_in, 
            pixel => pixel,
            image_dim => image_dim,           -- Added port
            image_dim_vld => image_dim_vld,   -- Added port
            image_finished => image_finished, 
            valid_out => valid_out,
            R => R, G => G, B => B
        );

    -- 2. Clock Generation
    clk_process : process
    begin
        while not sim_done loop 
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- 3. Stimulus Process
    stim_proc: process
        file input_file     : text;
        variable line_in    : line;
        variable pixel_temp : integer;
        variable status     : file_open_status;
        
        -- Variables for dynamic sizing tracking
        variable current_size  : integer;
        variable total_pix     : integer;
    begin
        -- Initial Reset
        rst_n <= '0';
        valid_in <= '0';
        image_dim_vld <= '0';
        wait for 25 ns;
        rst_n <= '1';
        wait for 20 ns;

        -----------------------------------------------------------
        -- FRAME 1: 32x32 Image (From File)
        -----------------------------------------------------------
        report "--- STARTING FRAME 1 (32x32) ---";
        current_size := 32;
        total_pix := current_size * current_size;
        
        -- Set Image Dimension
        image_dim <= std_logic_vector(to_unsigned(current_size, 11));
        image_dim_vld <= '1';
        wait for CLK_PERIOD;
        image_dim_vld <= '0';

        -- Signal start of image
        new_image <= '1';
        wait for CLK_PERIOD;
        new_image <= '0';
        wait until falling_edge(clk);
        
        -- Open file
        file_open(status, input_file, "/home/vasilis/Documents/MainFolder/uni/sem_8/VLSI/debayering_new/test1.data", read_mode);
        if status /= open_ok then
            report "FILE OPEN FAILED!" severity failure;
        end if;
        
        -- Phase A: Feed the real SIZE*SIZE pixels
        for i in 1 to total_pix loop
            if not endfile(input_file) then
                valid_in <= '1';
                readline(input_file, line_in);
                read(line_in, pixel_temp); 
                pixel <= std_logic_vector(to_unsigned(pixel_temp, 8));
            else
                pixel <= (others => '0');
            end if;
            wait for CLK_PERIOD;
        end loop;

        -- Phase B: The Pipeline Drain (DYNAMIC SYNC)
        report "Draining Frame 1 Pipeline...";
        pixel <= (others => '0');
        
        -- Keep pushing valid_in until the hardware says it is done
        while image_finished = '0' loop
            valid_in <= '1'; 
            wait for CLK_PERIOD;
        end loop;

        -- Hardware just asserted image_finished. 
        valid_in <= '0';
        file_close(input_file);
        report "Frame 1 Finished!";
        wait for CLK_PERIOD * 10; -- Idle gap between frames

        -----------------------------------------------------------
        -- FRAME 2: 16x16 Image (Synthetic Pattern Test)
        -----------------------------------------------------------
        report "--- STARTING FRAME 2 (16x16) DYNAMIC SIZE CHANGE ---";
        current_size := 16;
        total_pix := current_size * current_size;
        
        -- Update Image Dimension
        image_dim <= std_logic_vector(to_unsigned(current_size, 11));
        image_dim_vld <= '1';
        wait for CLK_PERIOD;
        image_dim_vld <= '0';

        -- Signal start of new image
        new_image <= '1';
        wait for CLK_PERIOD;
        new_image <= '0';
        
        -- Phase A: Feed synthetic counter pixels
        for i in 1 to total_pix loop
            valid_in <= '1';
            pixel <= std_logic_vector(to_unsigned(i mod 256, 8)); 
            wait for CLK_PERIOD;
        end loop;

        -- Phase B: The Pipeline Drain (DYNAMIC SYNC)
        report "Draining Frame 2 Pipeline...";
        pixel <= (others => '0');
        
        -- Keep pushing valid_in until the hardware says it is done
        while image_finished = '0' loop
            valid_in <= '1'; 
            wait for CLK_PERIOD;
        end loop;

        valid_in <= '0';
        report "Frame 2 Finished!";
        wait for CLK_PERIOD * 5;

        -----------------------------------------------------------
        -- End Simulation
        -----------------------------------------------------------
        sim_done <= true;
        report "Simulation Finished Successfully";
        wait;
    end process;
    
    -- 4. Data Logger Process
    logger_proc: process
        file output_file    : text;
        variable line_out   : line;
        variable status     : file_open_status;
    begin
        -- Open the file for writing
        file_open(status, output_file, "/home/vasilis/Desktop/output_results.data", write_mode);
        if status /= open_ok then
            report "OUTPUT FILE OPEN FAILED!" severity failure;
        end if;

        -- Header (Optional: helpful for post-processing)
        write(line_out, string'("R G B"));
        writeline(output_file, line_out);

        while not sim_done loop
            wait until rising_edge(clk);
            
            -- Capture data only when valid_out is high
            if valid_out = '1' then
                -- Write R value
                write(line_out, to_integer(unsigned(R)));
                write(line_out, string'(" ")); -- Space separator
                
                -- Write G value
                write(line_out, to_integer(unsigned(G)));
                write(line_out, string'(" "));
                
                -- Write B value
                write(line_out, to_integer(unsigned(B)));
                
                -- Commit the line to the file
                writeline(output_file, line_out);
            end if;
        end loop;

        file_close(output_file);
        report "Output file closed successfully.";
        wait;
    end process;

end sim;