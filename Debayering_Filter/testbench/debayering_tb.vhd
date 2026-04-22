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
    constant IMG_SIZE   : integer := 32;
    constant TOTAL_PIX  : integer := IMG_SIZE * IMG_SIZE; -- + 99;
    constant DRAIN_CYC  : integer := 2*IMG_SIZE + 4;

    -- Signals
    signal clk            : std_logic := '0';
    signal rst_n          : std_logic := '0';
    signal new_image      : std_logic := '0';
    signal valid_in       : std_logic := '0';
    signal pixel          : std_logic_vector(7 downto 0) := (others => '0');
    signal image_finished : std_logic;
    signal valid_out      : std_logic;
    signal R, G, B        : std_logic_vector(7 downto 0);
    
    file input_file     : text;
 
begin

    -- 1. DUT Instantiate
    uut: entity work.Debayering_Filter
        generic map ( size => IMG_SIZE )
        port map (
            clk => clk, rst_n => rst_n, new_image => new_image,
            valid_in => valid_in, pixel => pixel,
            image_finished => image_finished, valid_out => valid_out,
            R => R, G => G, B => B
        );

    -- 2. Clock Generation
    clk_process : process
    begin
      -- while now < 5000 ns loop 
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
      --  end loop;
      --  wait;
    end process;

    -- 3. Stimulus Process (With Controlled Drain)
    stim_proc: process
        variable line_in    : line;
        variable pixel_temp : integer;
        variable status     : file_open_status;
    begin
        -- Initial Reset
        rst_n <= '0';
        valid_in <= '0';
        wait for 25 ns;
        rst_n <= '1';
        wait for 20 ns;

        -- Signal start of image
        new_image <= '1';
        wait for CLK_PERIOD;
        new_image <= '0';
        wait until falling_edge(clk);
        -- Open file (ΔΙΟΡΘΩΜΕΝΟ PATH ΕΙΣΟΔΟΥ ΓΙΑ UBUNTU)
        file_open(status, input_file, "/home/vasilis/Documents/MainFolder/uni/sem_8/VLSI/debayering_new/test1.data", read_mode);
        
        if status /= open_ok then
            report "FILE OPEN FAILED!" severity failure;
        end if;
        
        -- Phase A: Feed the real SIZE*SIZE pixels
        for i in 1 to TOTAL_PIX loop
            if not endfile(input_file) then
                --if i > 100 AND i< 200 then
                --    valid_in <= '0';
                --else    
                    valid_in <= '1';
                    readline(input_file, line_in);
                    read(line_in, pixel_temp); 
                    pixel <= std_logic_vector(to_unsigned(pixel_temp, 8));
                --end if;
            else
                report "Warning: File ended earlier than SIZE*SIZE" severity warning;
                pixel <= (others => '0');
            end if;
            wait for CLK_PERIOD;
        end loop;

        -- Phase B: The Pipeline Drain
        report "Starting Pipeline Drain Phase";
        pixel <= (others => '0');
        for i in 1 to DRAIN_CYC loop
            valid_in <= '1'; 
            wait for CLK_PERIOD;
        end loop;

        -- Phase C: Finalize
        valid_in <= '0';
        file_close(input_file);
        
        wait until image_finished = '1';
        wait for CLK_PERIOD * 5;
        
        report "Simulation Finished Successfully";
        assert false report "End of Simulation" severity failure;
        wait;
    end process;
    
  -- 4. Results Recording Process (ΔΙΟΡΘΩΜΕΝΟ ΜΕ ΠΡΟΣΤΑΣΙΑ file_is_open)
    write_results_proc: process(clk)
        file output_file     : text;
        variable out_line    : line;
        variable status      : file_open_status;
        variable file_is_open: boolean := false;
    begin
        if rst_n = '0' then
            --my path 
            file_open(status, output_file, "/home/vasilis/Documents/MainFolder/uni/sem_8/VLSI/debayering_new/output_pixels1.data", write_mode);
            file_is_open := true;
        elsif rising_edge(clk) then
            if valid_out = '1' and file_is_open then
                write(out_line, to_integer(unsigned(R)));
                write(out_line, ' ');
                write(out_line, to_integer(unsigned(G)));
                write(out_line, ' ');
                write(out_line, to_integer(unsigned(B)));
                writeline(output_file, out_line);
            end if;

            if image_finished = '1' and file_is_open then
                file_close(output_file);
                file_is_open := false;
            end if;
        end if;
    end process;

end sim;
