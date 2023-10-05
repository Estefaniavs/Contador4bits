library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DSP is
	Port ( clk : in  STD_LOGIC; --El clk crea los pulsos de reloj
          rst : in  STD_LOGIC; -- RESET
          digitos : out  STD_LOGIC_VECTOR (3 downto 0);  
          seven_seg : out  STD_LOGIC_VECTOR (7 downto 0)); 
			  
end DSP;

architecture Behavioral of DSP is
	signal counterA : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Contador de las unidades
	signal counterB : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Contador de las decenas
	signal counterC : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Contador de las centenas
	signal counterD : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Contador de las unidades de millar 
	signal counter : STD_LOGIC_VECTOR(3 downto 0) := "0000"; 
	signal secuencia : STD_LOGIC_VECTOR(1 downto 0) := "00"; --Lleva la secuencia entre los displays 
	
   signal clk_counter : STD_LOGIC_VECTOR(25 downto 0) := (others => '0');  -- Lleva la frecuencia del contador 
   signal clk_counter2 : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
	signal seg_signals : STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --Punto G F E D C B A acomodo de 0 y 1 para activacion de display
	
begin

	process (clk, rst)  --Este process lleva el conteo de unidades, decenas, centenas y unidades de millar
		begin				  
			if rst = '1' then -- Si se selecciona reset todos los contadores y el contador de reloj se reinician a 0 
				counterA <= "0000"; 				
				counterB <= "0000";
				counterC <= "0000";
				counterD <= "0000";
            clk_counter <= (others => '0');
			elsif rising_edge(clk) then --Cada que haya un pulso ascendente entonces cuenta el contador del reloj 
            clk_counter <= clk_counter + 1;  -- Incrementar el contador
            if clk_counter = "00000011110100001001000000" then --Cuando el contador complete los 1MHz se reinicia  
					clk_counter <= (others => '0');
               counterA <= counterA + 1;   -- Cada que el contador de las unidades llegue a 9 entonces se reinicia
					if counterA = "1001" then   --NOTA los contadores cuentan en binario 
                  counterA <= "0000";		 -- Cada que el contador de las unidades llegue a 9 entonces hay un pulso para que empiecen
						counterB <= counterB + 1;-- a contar el contador de las decenas 
						if counterB = "1001" then	-- Cada que el contador de las decenas llegue a 9 entonces se reinicia
							counterB <= "0000";
							counterC <= counterC + 1;  
							if counterC = "1001" then -- Cada que el contador de las centenas llegue a 9 entonces se reinicia
								  counterC <= "0000";
								  counterD <= counterD + 1;
							 end if;
						end if;
               end if;
            end if;				
        end if;
    end process;
	 
	process (clk) -- Este process se encarga de llevar la secuencia entre displays 
		begin
			if rising_edge(clk) then 
            clk_counter2 <= clk_counter2 + 1; 
            if clk_counter2 = "00110010110111001101" then  
					secuencia <= secuencia + 1;
					clk_counter2 <= (others => '0');
				end if;
			end if;			
	end process;
	
process (secuencia,counterA,counterB,counterC,counterD) -- Este process es el decodificador de secuencia a binario 
		begin
			case secuencia is 
			when "00" => 
				counter <= counterA;
				digitos <= "1110"; --Cuando counter se asigne al counter de las unidades el display 0 se activa 
			when "01" => 
				counter <= counterB;
				digitos <= "1101"; --Cuando counter se asigne al counter de las unidades el display 1 se activa
			when "10" => 
				counter <= counterC;
				digitos <= "1011"; --Cuando counter se asigne al counter de las unidades el display 2 se activa
			when "11" => 
				counter <= counterD;
				digitos <= "0111"; --Cuando counter se asigne al counter de las unidades el display 3 se activa
			when others =>
				counter <= "1111"; --Cualquier otro caso entonces se desactivan todos los displays 
				digitos <= "1111";
			end case;
	end process;

	process (counter)	-- Este process es el decodificador de binario al display de 7 segmentos
		begin
			case counter is								-- Punto G F E D C B A
				when "0000" =>
                seg_signals <= not "00111111";  -- Mostrar 0
            when "0001" =>
                seg_signals <= not "00000110";  -- Mostrar 1
            when "0010" =>
                seg_signals <= not "01011011";  -- Mostrar 2
				when "0011" =>
					seg_signals <= not "01001111";   -- Mostrar 3
            when "0100" =>
                seg_signals <= not "01100110";  -- Mostrar 4
            when "0101" =>
                seg_signals <= not "01101101";  -- Mostrar 5
				when "0110" =>	
					 seg_signals <= not "01111101";  -- Mostrar 6
            when "0111" =>
                seg_signals <= not "00000111";  -- Mostrar 7
            when "1000" =>
                seg_signals <= not "01111111";  -- Mostrar 8
				when "1001" =>
                seg_signals <= not "01101111";  -- Mostrar 9
            when others =>
					seg_signals <= not "00000000";  -- Mostrar algo no válido (todos los segmentos apagados)
			end case;
	end process;

seven_seg <= seg_signals;

end Behavioral;