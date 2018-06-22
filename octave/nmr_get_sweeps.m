% Split data into sweeps, return cell arrays with time, current, x, y

function [TS IS XS YS] = nmr_get_sweeps(T,I,X,Y, sweep_minpts)

  % default value for sweep_minpts
  if nargin<5; sweep_minpts=20; end

  % find points where sweep direction changes
  dir=2;
  ipr=I(1);
  sw = [];

  for i=2:length(I)
    d=0;
    if I(i)>ipr; d=1;  end
    if I(i)<ipr; d=-1; end
    if d!=dir;
      sw(end+1) = i-1;
      dir=d;
    end
    if d!=0
      ipr=I(i);
    end
  end
  sw(end+1) = length(I);

  % split data
  TS={}; IS={}; XS={}; YS={};
  for i=2:length(sw);
    ii = sw(i-1):sw(i);
    % skip short sweeps
    if length(ii) < sweep_minpts; continue; end
    % sweep dir=0 sweeps
    if I(ii(1))==I(ii(end)) continue; end
    TS{end+1} = T(ii);
    IS{end+1} = I(ii);
    XS{end+1} = X(ii);
    YS{end+1} = Y(ii);
  end

  if (0)
    find_figure('nmr_get_sweeps'); clf; hold on;
    for i=1:length(TS)
      plot(T(sw)-T(1), I(sw), 'b*');
      plot(TS{i}-T(1), IS{i}, 'r-');
    end
  end

end
