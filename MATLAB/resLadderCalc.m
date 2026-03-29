%% Resistor ladder calculator
% Calculates resistor ladder values based on given input voltage, total
% current and voltage tap values.
% Author: A.Sidun
% Source: AnalogHub.ie

clear all
clc

%% User inputs
Vin = 1;                                % Input voltage (V)
Iin = 1e-3;                             % Total current (I)
Voltages = [0.7, 0.2, 0.4, 0.9];        % Desired voltage outputs (V)

%% Calculations
Rtot = Vin/Iin;                         % total ladder resistance
Voltages = sort(Voltages);              % sort voltages (ascending)
res(1) = Voltages(1)/Iin;               % first resistor value from ground

% Consequent resistors
for i = 2:length(Voltages)              
    res(i) = (Voltages(i)-Voltages(i-1))/Iin;
end

res(length(Voltages)+1) = Rtot - sum(res);% last resistor
res = flip(res);                          % flip resistor order for display

Voltages = [0, Voltages];                 % adding GND to array
Voltages = flip(Voltages);                % flip resistor order for display 

%% Results display
disp("-------------------------------------")
disp("==== Resistor ladder calculation ====")
disp("-------------------------------------")

% Display total resistance value
if fix(Rtot/1e6)>0                          % if MOhm
    disp("====       Rtotal: " + Rtot/1e6 + " MOhm        ====")
elseif fix(Rtot/1e3)>0                      % if kOhm
    disp("====       Rtotal: " + Rtot/1e3 + " kOhm        ====")
else                                        % if Ohm
    disp("====       Rtotal: " + Rtot + " Ohm        ====")
end
disp("-------------------------------------")
disp(" ")
disp("**** Vin=" + Vin + "V ****")
disp(" ")

% Display resistor values 
for i = 1:length(res)
    if fix(res(i)/1e6)>0                    % if Mohm
        disp("R" + i + " : "  + res(i)/1e6 + " MOhm")
    elseif fix(res(i)/1e3)>0                % if kohm
        disp("R" + i + " : "  + res(i)/1e3 + " kOhm")
    else                                    % if Ohm
        disp("R" + i + " : "  + res(i) + " Ohm")
    end
    % Display tap voltage values   
    if i<(length(res))
        disp("              --> Vout= " + Voltages(i) + " V ")
    end
end

disp(" ")
disp("**** GND=0V ****")
