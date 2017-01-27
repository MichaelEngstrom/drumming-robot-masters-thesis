%Interface for launching Beat Detection script W/O DEVICE CONNECTED
%##########################################################################
%########################--MATLAB CODE--###################################
%##########################################################################
%What is the COM port name?
%       input COM port name
%       SerBEAT = serial([Com port name]);
%Do you want to use a .wav file or the microphone?
% if file then
%       input file name
%       test = strcat('xx', num2str(control([file name])))
% else
% ...
%
%NOTE:
%If MATLAB gives a serial error, it will most likely say 'unable to open
%serial port' next time you run the program; restart MATLAB to recover.
%
loop_val =1;
repeat_val = 0;
    
%prompt = 'Enter your COM port: ';
%str = input(prompt,'s');
%prompt2 = strcat(str, ': Is this correct? Y/N [Y]: ');
%str2 = input(prompt2,'s');
%if (strcmp(str2, 'Y') || strcmp(str2, 'y'))
%    SerBEAT = serial(str); %<--change this appropriately
%    set(SerBEAT,'BaudRate', 9600, 'DataBits', 8, 'Parity', 'none','StopBits', 1, 'FlowControl', 'none');
%    fopen(SerBEAT); %--open the serial port to the PIC

    while loop_val == 1
         if (repeat_val ~= 1)
            prompt3 = ('Enter .wav file name, M for microphone, or Z to pause: ');
            str3 = input(prompt3,'s');
            if (strcmp(str3, 'M') || strcmp(str3, 'm') || isempty(str3))
                BPM = control_accurate();
            elseif (strcmp(str3, 'Z') || strcmp(str3, 'z'))
                BPM = 1;     %set to zero so Mode check drops out to PAUSE
            else
                BPM = control_accurate(str3);
            end
         else
            BPM = control_accurate();
         end
        %%%%%%%%%%%%Logic for beat mode to send to Robot Controller%%%%%%%%%
%         while ((BPM > 120) || (BPM < 60))
%             if BPM > 120
%                 BPM = (BPM / 2);
%             end
%             if BPM < 60
%                 BPM = (BPM * 2);
%             end
%         end
%        pause(1)
        BPM
        %Mode = (ceil((BPM - 59)/6)-1);
        if ((BPM > 59) && (BPM < 62))         %60-61 BPM
            Mode = 'a'; %60 BPM
        elseif ((BPM > 61) && (BPM < 65))     %62-64 BPM
            Mode = 'b'; %62 BPM
        elseif ((BPM > 64) && (BPM < 68))     %65-67 BPM
            Mode = 'c'; %65 BPM
        elseif ((BPM > 67) && (BPM < 70))     %68-69 BPM
            Mode = 'd'; %68 BPM
        elseif ((BPM > 69) && (BPM < 72))     %70-71 BPM
            Mode = 'e'; %70 BPM
        elseif ((BPM > 71) && (BPM < 75))     %72-74 BPM
            Mode = 'f'; %72 BPM
        elseif ((BPM > 74) && (BPM < 78))     %75-77 BPM
            Mode = 'g'; %75 BPM
        elseif ((BPM > 77) && (BPM < 80))    %78-79 BPM
            Mode = 'h'; %78 BPM
        elseif ((BPM > 79) && (BPM < 82))    %80-81 BPM
            Mode = 'i'; %80 BPM
        elseif ((BPM > 81) && (BPM < 85))   %82-84 BPM
            Mode = 'j'; %82 BPM
        elseif ((BPM > 84) && (BPM < 88))   %85-87 BPM
            Mode = 'k'; %85 BPM
        elseif ((BPM > 87) && (BPM < 90))   %88-89 BPM
            Mode = 'l'; %88 BPM
        elseif ((BPM > 89) && (BPM < 92))   %90-91 BPM
            Mode = 'm'; %90 BPM
        elseif ((BPM > 91) && (BPM < 95))   %92-94 BPM
            Mode = 'n'; %92 BPM
        elseif ((BPM > 94) && (BPM < 98))   %95-97 BPM
            Mode = 'o'; %95 BPM
        elseif ((BPM > 97) && (BPM < 100))   %98-99 BPM
            Mode = 'p'; %98 BPM
        elseif ((BPM > 99) && (BPM < 102))   %100-101 BPM
            Mode = 'q'; %100 BPM
        elseif ((BPM > 101) && (BPM < 105))   %102-104 BPM
            Mode = 'r'; %102 BPM
        elseif ((BPM > 104) && (BPM < 108))   %105-107 BPM
            Mode = 's'; %105 BPM
        elseif ((BPM > 107) && (BPM < 110))   %108-109 BPM
            Mode = 't'; %108 BPM
        elseif ((BPM > 109) && (BPM < 112))   %110-111 BPM
            Mode = 'u'; %110 BPM
        elseif ((BPM > 111) && (BPM < 115))   %112-114 BPM
            Mode = 'v'; %112 BPM
        elseif ((BPM > 114) && (BPM < 118))   %115-117 BPM
            Mode = 'w'; %115 BPM
        elseif ((BPM > 117) && (BPM < 120))   %118-119 BPM
            Mode = 'x'; %118 BPM
        elseif ((BPM > 119) && (BPM < 121))   %120 BPM
            Mode = 'y'; %120 BPM
        elseif (BPM < 5)    %user has input a z or Z
            Mode = 'z';         %Drum is PAUSED
        end
%        pause(1);
        Mode
        %Mode value key:
        % a = 60 BPM
        % b = 62 BPM
        % c = 65 BPM
        % d = 68 BPM
        % e = 70 BPM
        % f = 72 BPM
        % g = 75 BPM
        % h = 78 BPM
        % i = 80 BPM
        % j = 82 BPM
        % k = 85 BPM
        % l = 88 BPM
        % m = 90 BPM
        % n = 92 BPM
        % o = 95 BPM
        % p = 98 BPM
        % q = 100 BPM
        % r = 102 BPM
        % s = 105 BPM
        % t = 108 BPM
        % u = 110 BPM
        % v = 112 BPM
        % w = 115 BPM
        % x = 118 BPM
        % y = 120 BPM
        %%%%%%%%%%%%End Beat Mode Logic%%%%%%%%%
 %       if Mode == 13
 %           Mode = 12;
 %       end
 %       switch Mode
 %           case 0
 %               test = 'Mode 0: 60-65 BPM'
 %           case 1
  %              test = 'Mode 1: 66-71 BPM'
 %           case 2
 %               test = 'Mode 2: 72-77 BPM'
 %           case 3
 %               test = 'Mode 3: 78-83 BPM'
 %           case 4
 %               test = 'Mode 4: 84-89 BPM'
 %           case 5
  %              test = 'Mode 5: 90-95 BPM'
 %           case 6
 %               test = 'Mode 6: 96-101 BPM'
 %           case 7
  %              test = 'Mode 7: 102-107 BPM'
 %           case 8
 %               test = 'Mode 8: 108-113 BPM'
 %           case 9
 %               test = 'Mode 9: 114-120 BPM'
  %      end
                
        %test = num2str(Mode);
        %test = strcat(':::', num2str(Mode));
    %    for s = 1: 1: 100
            %fprintf(SerBEAT, '%s', test); %--send BPM mode to Orangutan Robot Controller
    %        pause(0.1);
    %    end
    if (repeat_val ~= 1)
        prompt4 = 'Press: R=Repeat, B=BPM Detect Loop (CTRL+C to exit), or Q=finish: ';
        str4 = input(prompt4,'s');

        if (strcmp(str4, 'Q') || strcmp(str4, 'q'))
            loop_val = 0;
            %fclose(SerBEAT) %--close the serial port when done
            %delete(SerBEAT)
            %clear SerBEAT
        elseif (strcmp(str4, 'B') || strcmp(str4, 'b'))
            repeat_val = 1;
        elseif (strcmp(str4, 'R') || strcmp(str4, 'r') || isempty(str4))
            repeat_val = 0;
        end
    end
    pause(1);
 end
%else
    %exit
%end

%NOTE 1:
%if MATLAB ever gives a serial error, it will most likely say 'unable to
%open serial port' next time you
%run the program, so you have to restart MATLAB
%
%http://www.instructables.com/id/MATLAB-to-PIC-serial-interface/