% Split data into sweeps

function [TS IS XS YS] = nmr_get_sweeps(T,I,X,Y, sweep_minpts)

  % default value for sweep_minpts
  if nargin<5; sweep_minpts=10; end

  % find points where sweep direction changes
  dir=2;
  ipr=I(1);
  sw = [];
  for i=2:length(I)
    d=0;
    if I(i)>ipr; d=1;  end
    if I(i)<ipr; d=-1; end
    if d!=0 && d!=dir;
      sw(end+1) = i-1;
      dir=d;
    end
    ipr=I(i);
  end
  sw(end+1) = length(I);

  % split data
  TS={}; IS={}; XS={}; YS={};
  for i=2:length(sw);
    ii = sw(i-1):sw(i);
    if length(ii) < sweep_minpts; continue; end
    TS{end+1} = T(ii);
    IS{end+1} = I(ii);
    XS{end+1} = X(ii);
    YS{end+1} = Y(ii);
  end
end
