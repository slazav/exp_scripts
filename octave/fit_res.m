% For a resonance curve (amp vs freq) find
% the maximum f0,a0 (using a simple 3-pt quadratic fit)
% and q-factor Q=f0/df, where df is a width at a0*lvl.

% There is a tcl version of this code

function [f0 Q a0 xl xr] = fit_res(fv, av, lvl)

  f0=0; Q=0; a0=0; xl=0; xr=0;

  if nargin<3; lvl=1.0/sqrt(2); end

  # find index of point with maximal amplitude
  [~, maxi] = max(av);
  if maxi == 1 || maxi == length(fv); return; end
    # error "fit_res: can't find maximum";

  # calculate maximum (3-pt quadratic fit)
  f1=fv(maxi-1); f2=fv(maxi); f3=fv(maxi+1);
  a1=av(maxi-1); a2=av(maxi); a3=av(maxi+1);

  D= f1^2*(f2-f3) + f2^2*(f3-f1) + f3^2*(f1-f2);
  if D==0; return; end
    # error "fit_res: zero determinant in quadratic fit";

  A  = (a1*(f2-f3) + a2*(f3-f1) + a3*(f1-f2))/D;
  B  = (f1^2*(a2-a3) + f2^2*(a3-a1) + f3^2*(a1-a2))/D;
  C  = (f1^2*(f2*a3-f3*a2) + f2^2*(f3*a1-f1*a3) + f3^2*(f1*a2-f2*a1))/D;
  f0 = -B/A/2.0;
  a0 = C-B^2/A/4.0;

  # calculate width at 1/2 amplitude
  aa = a0*lvl;

  # right side
  for i=maxi:1:length(fv)-1
    a1 = av(i);
    a2 = av(i+1);
    if a1 >= aa && a2 < aa
      f1 = fv(i);
      f2 = fv(i+1);
      # linear interpolation between points
      xr = f1 + (f2-f1)*(aa-a1)/(a2-a1);
    end
  end

  # left side
  for i=maxi:-1:2
    a1 = av(i);
    a2 = av(i-1);
    if (a1 >= aa && a2 < aa)
      f1 = fv(i);
      f2 = fv(i-1);
      # linear interpolation between points
      xl = f1 + (f2-f1)*(aa-a1)/(a2-a1);
    end
  end
  if exist('xr')!=1 || exist('xl')!=1; return; end
    #error "fit_res: can't get curve width";

  Q = f0/(xr-xl);

end
