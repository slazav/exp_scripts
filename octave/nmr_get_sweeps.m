% Split data into sweeps, return cell arrays with time, current, x, y
%
% Options:
%  -min_n <number>  -- min.number of points for sweep selection (default 20)
%  -min_t <time, s> -- min.sweep time (default 0)
%  -min_i <current, mA> -- min.current span (default 0)
%  -max_r <rate,mA/s> -- max.sweep rate (if 0 then no check; default 0)
%  -min_r <rate,mA/s> -- min.sweep rate (default 0)
%  -skip_const 0|1 -- skip constant-current ranges (default 1)
%  -do_plot 0|1 -- plot sweeps (default 0)


function [TS IS XS YS] = nmr_get_sweeps(T,I,X,Y, varargin)

  if (nargin < 4)
    error "Usage: nmr_get_sweeps(T,I,X,Y, [options]";
  endif

  # default parameters
  min_n = 20;
  min_t = 0;
  min_i = 0;
  min_r = 0;
  max_r = 0;
  do_plot=0;
  skip_const=1;

  # parse options
  idx = [];
  if ( nargin > 4)
    for i = 1:nargin-4
      arg = varargin{i};
      if ischar(arg)
        switch arg
          case "min_n";  min_n = varargin{i+1}; idx = [idx,i,i+1];
          case "min_t";  min_t = varargin{i+1}; idx = [idx,i,i+1];
          case "min_i";  min_i = varargin{i+1}; idx = [idx,i,i+1];
          case "min_r";  min_r = varargin{i+1}; idx = [idx,i,i+1];
          case "max_r";  max_r = varargin{i+1}; idx = [idx,i,i+1];
          case "do_plot";    do_plot    = varargin{i+1}; idx = [idx,i,i+1];
          case "skip_const"; skip_const = varargin{i+1}; idx = [idx,i,i+1];
        endswitch
      endif
    endfor
  endif
  varargin(idx) = [];
  options = varargin;


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
    n=length(ii);
    dt = T(ii(end))-T(ii(1)); % s
    di = 1e3*abs(I(ii(end))-I(ii(1))); % mA
    r = di/dt; % mA/s

    % skip sweeps
    if min_n>0 && n  <= min_n; continue; end
    if min_t>0 && dt <= min_t; continue; end
    if min_i>0 && di <= min_i; continue; end
    if min_r>0 && r  <= min_r; continue; end
    if max_r>0 && r  >= max_r; continue; end
    if skip_const && di==0; continue; end

    TS{end+1} = T(ii);
    IS{end+1} = I(ii);
    XS{end+1} = X(ii);
    YS{end+1} = Y(ii);
  end

  if (do_plot)
    find_figure('nmr_get_sweeps'); clf; hold on;
    for i=1:length(TS)
      plot(TS{i}-T(1), IS{i}, 'r-');
      plot(TS{i}(1)-T(1), IS{i}(1), 'b*');
      plot(TS{i}(end)-T(1), IS{i}(end), 'b*');
    end
  end

end
