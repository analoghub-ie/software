%% PCB lumped parameters calculator (microstrip/stripline)
% Author: A.Sidun
% Source: AnalogHub.ie
% Limitations:
% - Valid under 1GHz
% - Skin effect is omitted
% - Copper roughness is omitted
% - Loss tangent is omitted
% - Geometry limitations:
% W/H < 7.475 - 1.25*(T/H) -  for a microstrip
% W/B < 2.375 - 1.25*(T/B) - for a stripline
% Source: https://resources.system-analysis.cadence.com/blog/msa2021-is-there-a-pcb-trace-inductance-rule-of-thumb

%% Input parameters
type = "microstrip";				% can be microstrip or stripline
temp = 25;					% temperature [C]
length = 1e-3;					% trace length [m]
width = 0.5e-3;                                 % trace width [m]
thickness = 35e-6;				% trace thickness [m]
height = 0.4e-3;				% height over a plane [m] 

%% Constants
ro = 1.724e-8;					% resistivity of copper [Ohm/m]
alpha = 3.9e-3;					% temperature coefficient of copper
eps_r = 4.46;					% relative permittivity of copper

%% Calculations
B = 2*height+thickness;				% plane-to-plane distance [m]
switch type
    case "microstrip"
        if ( width/height < 7.475 - 1.25*(thickness/height) )
            R_lumped = 1e3*ro*(1 + alpha*(temp-25))/(thickness*width);				% mOhms/meter
            C_lumped = 26.378*(eps_r+1.41)/( log( 5.98*height/(0.8*width+thickness) ) );	% pF/meter
            L_lumped = 199.65*log( 5.98*height/(0.8*width + thickness) );			% nH/meter
            Z = 87*log(5.98*height/(0.8*width + thickness)) / sqrt(eps_r + 1.41);
            
            R = R_lumped*length; % mOhm
            L = L_lumped*length; % nH
            C = C_lumped*length; % pF
            
            disp("PCB " + type + " parameters:")
            disp("R = " + R + " mOhms")
            disp("C = " + C + " pF")
            disp("L = " + L + " nH")
            disp("Z = " + Z + " Ohm")
        else 
          disp("Please check geometry of the trace.")  
        end
     case "stripline"
        if ( width/B < 2.375 - 1.25*(thickness/B) )
           R_lumped = 1e3*ro*(1 + alpha*(temp-25))/(thickness*width);                   % mOhms/meter
           C_lumped = 39.37*eps_r*sqrt(2) / ( log(1.9*B/(0.8*width + thickness)) );     % pF/meter
           L_lumped = 199.8425*log( 1.9*B/(0.8*width + thickness) );                    % nH/meter
           Z = 60*log(1.9*B/(0.8*width + thickness)) / sqrt(eps_r); 
           
           R = R_lumped*length; % mOhm
           L = L_lumped*length; % nH
           C = C_lumped*length; % pF
           
           disp("PCB " + type + " parameters:")
           disp("R = " + R + " mOhms")
           disp("C = " + C + " pF")
           disp("L = " + L + " nH")
           disp("Z = " + Z + " Ohm")
         else 
          disp("Please check geometry of the trace.")  
        end
end
