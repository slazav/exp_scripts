% Rotate phase of the nmr signal (phase in degrees)

function [xn,yn] = nmr_chphase(x, y, ph)
  xn =  x*cos(ph*pi/180) + y*sin(ph*pi/180);
  yn = -x*sin(ph*pi/180) + y*cos(ph*pi/180);
end
