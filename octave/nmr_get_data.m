% Get NMR data (time, current, x, y) for a time range
% additonal parameters can be returned in pars
%
%
% Options:
%
%  dbpref <string> -- Prefix for graphene program.
%
%  verb 1|0 -- Be verbose (default: 0).
%
%  sweeps 1|0 -- Split current sweeps, return cell arrays (default: 0).
%    All options below are valid only in this mode.
%
%  sweep_min_n, sweep_min_t, sweep_min_i, sweep_min_r,
%  sweep_max_n, sweep_max_t, sweep_max_i, sweep_max_r -- Select sweeps with
%    number of points, time span (ion seconds), current span (in mA),
%    time/current rate (in mA/s) within some limits.
%    If limit is 0 it is not used. Defaults are 20 for sweep_min_n and 0
%    for other limits.
%
%  sweep_nonconst 1|0 -- skip "constant sweeps", ones without current change.
%    Default is 1.
%
%  sweep_plot 0|1 -- plot sweeps (default 0)
%
%  fix_drift 'none'|'pairs'|'global' -- Fix signal drift.
%
%    If the parameter value is 'pairs' than fix the drift for each
%    sweep pair separately. Two points are selected in two sweeps
%    with same current but largest time between them; Signal assumed to
%    be same in these points, drift assumed to be linear.
%    This method removes only a drift within each pair.
%
%    If the parameter value is 'global' then drift is calculated
%    for all sweeps. All sweeps should be done in the same current range
%    Default is 'none'.
%
%  drift_plot 0|1 -- plot drift (default 0)
%
%  fix_phase 'none'|'first'|'last'|'mean'|'separate' --
%     Adjust signal phase and subtract baseline.
%     Parameter value shows how phase is calculated
%     'first': use first sweep to detect the phase
%     'last':  use last sweep to detect the phase
%     'average': use average value for all sweeps
%     'separate': use values for each sweep separately
%     'none': do nothing -- (default)
%     If phase and baseline is fixed, then pars.ph, pars.x0, pars.y0
%     are returned.
%
%  phase_plot 0|1 -- plot phase (default 0)
%
%  get_freq, get_exc, get_com 1|0 -- get generator frequency, excitation and
%    compensation amplitudes for each sweep (default: 0)
%  get_grad, get_quad, get_helm 1|0 -- get magnet currents for each sweep
%  get_temp 1|0 -- get NS temperature
%    (default: 0)


function [T,I,X,Y, pars] = nmr_get_data(t1, t2, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% default parameters
  dbpref='graphene -d /home/exports/DB';
  verb  = 0;
  sweeps  = 0;

  sweep_min_n = 20;
  sweep_min_t = 0;
  sweep_min_i = 0;
  sweep_min_r = 0;
  sweep_max_n = 0;
  sweep_max_t = 0;
  sweep_max_i = 0;
  sweep_max_r = 0;
  sweep_nonconst=1;
  sweep_plot=0;

  fix_drift  = 'none';
  drift_plot=0;

  fix_phase = 'none';
  phase_plot=0;

  get_freq = 0;
  get_exc = 0;
  get_com = 0;
  get_grad = 0;
  get_quad = 0;
  get_helm = 0;
  get_temp = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% parse options
  if (nargin < 2)
    error "Usage: nmr_get_data(t1,t2, [options]";
  endif

  idx = [];
  if ( nargin > 2)
    for i = 1:2:nargin-2
      arg = varargin{i};
      if !ischar(arg)
        error("nmr_get_data: unknown non-character option");
      end
      switch arg
        case "dbpref"; dbpref = varargin{i+1}; idx = [idx,i,i+1];
        case "verb";   verb   = varargin{i+1}; idx = [idx,i,i+1];
        case "sweeps"; sweeps = varargin{i+1}; idx = [idx,i,i+1];

        case "sweep_min_n";  sweep_min_n  = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_max_n";  sweep_max_n  = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_min_t";  sweep_min_t  = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_max_t";  sweep_max_t  = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_min_i";  sweep_min_i  = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_max_i";  sweep_max_i  = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_min_r";  sweep_min_r  = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_max_r";  sweep_max_r  = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_nonconst"; sweep_nonconst = varargin{i+1}; idx = [idx,i,i+1];
        case "sweep_plot";   sweep_plot    = varargin{i+1}; idx = [idx,i,i+1];

        case "fix_drift";   fix_drift    = varargin{i+1}; idx = [idx,i,i+1];
        case "drift_plot";  drift_plot   = varargin{i+1}; idx = [idx,i,i+1];

        case "fix_phase";   fix_phase    = varargin{i+1}; idx = [idx,i,i+1];
        case "phase_plot";  phase_plot   = varargin{i+1}; idx = [idx,i,i+1];

        case "get_freq";   get_freq    = varargin{i+1}; idx = [idx,i,i+1];
        case "get_exc";    get_exc     = varargin{i+1}; idx = [idx,i,i+1];
        case "get_com";    get_com     = varargin{i+1}; idx = [idx,i,i+1];
        case "get_grad";   get_grad    = varargin{i+1}; idx = [idx,i,i+1];
        case "get_quad";   get_quad    = varargin{i+1}; idx = [idx,i,i+1];
        case "get_helm";   get_helm    = varargin{i+1}; idx = [idx,i,i+1];
        case "get_temp";   get_temp    = varargin{i+1}; idx = [idx,i,i+1];
        otherwise; error(["nmr_get_data: unknown option: " arg]);
      endswitch
    endfor
  endif
  varargin(idx) = [];
  options = varargin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get nmr data


  % convert string dates to unix seconds
  if length(t1)>0; t1=date2unix(t1); end
  if length(t2)>0; t2=date2unix(t2); end

  % construct db query
  dbname='drydemag_sweep_main';
  cmd=[dbpref ' get_range ' dbname ' ' num2str(t1) ' ' num2str(t2)];

  if verb
    fprintf("Get NMR data: %s - %s (%.0f-%.0f):\n",...
            unix2date(t1), unix2date(t2),t1,t2);
  end

  % run command and parse result
  [~, data] = system(cmd);
  [T,IM,I,V,X,Y] = strread(data, '%f %f %f %f %f %f');
  if verb
    fprintf("  %d data points\n", length(T));
  end

  if (!sweeps) return; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% split sweeps

  % find points where sweep direction changes
  dir=2;
  ipr=I(1);
  sw = [];

  if verb; fprintf("Select current sweeps:\n");  end

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

    % select sweeps
    if sweep_min_n>0 && n  <= sweep_min_n; continue; end
    if sweep_min_t>0 && dt <= sweep_min_t; continue; end
    if sweep_min_i>0 && di <= sweep_min_i; continue; end
    if sweep_min_r>0 && r  <= sweep_min_r; continue; end
    if sweep_max_r>0 && r  >= sweep_max_r; continue; end
    if sweep_nonconst && di==0; continue; end

    TS{end+1} = T(ii);
    IS{end+1} = I(ii);
    XS{end+1} = X(ii);
    YS{end+1} = Y(ii);
  end
  T=TS; I=IS; X=XS; Y=YS;
  TS={}; IS={}; XS={}; YS={};
  clear IS XS YS;

  if verb; fprintf("  %d sweeps\n", length(T));  end

  if (sweep_plot)
    find_figure('nmr_data: sweeps'); clf; hold on;
    for i=1:length(T)
      plot(T{i}-T{1}(1), I{i}, 'r-');
      plot(T{i}(1)-T{1}(1), I{i}(1), 'b*');
      plot(T{i}(end)-T{1}(1), I{i}(end), 'b*');
    end
    xlabel('time, s')
    ylabel('current, I')
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get some sweep parameters (will be used later)

  for i=length(T):-1:1;
    pars.tmean(i) = mean(T{i});
    pars.imean(i) = mean(I{i});
    pars.tspan(i) = T{i}(end)-T{i}(1);
    pars.ispan(i) = abs(I{i}(end)-I{i}(1));
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% fix drift

  if !strcmp(fix_drift, 'none') &&...
     !strcmp(fix_drift, 'pairs') &&...
     !strcmp(fix_drift, 'global');
    error('Unknown fix_drift setting, should be "none", "pairs" or "global"')
  end

  if (drift_plot)
    find_figure('nmr_get_data: drift'); clf; hold on;
  end

  if verb
    fprintf("Fix drift: %s\n", fix_drift);
  end

  %%%% 'pairs' method
  if (strcmp(fix_drift, 'pairs'))
    % for each pair
    for ip=1:2:length(I)-1

      % let's find farthest points in the pair with same current
      i2 = interp1(I{ip+1}, 1:length(I{ip+1}), I{ip}(1), 'nearest', 'extrap');
      i1 = interp1(I{ip},   1:length(I{ip}),   I{ip+1}(end), 'nearest', 'extrap');
      if isnan(i2) || isnan(i1)
        msg=['nmr_get_data: fix_drift=pairs: skip sweeps ' num2str(ip) ' - ' num2str(ip+1)];
        warning msg
        continue
      end
      if T{ip+1}(end)-T{ip}(i1) > T{ip+1}(i2)-T{ip}(1)
        i2=length(T{ip+1});
      else
        i1=1;
      end

      dx = X{ip+1}(i2)-X{ip}(i1);
      dy = Y{ip+1}(i2)-Y{ip}(i1);
      dt = T{ip+1}(i2)-T{ip}(i1);

      if (drift_plot)
        t = [T{ip}; T{ip+1}] - T{1}(1);
        x = [X{ip}; X{ip+1}];
        y = [Y{ip}; Y{ip+1}];
        ii = [i1 i2+length(T{ip})];
        plot(t, x,   'r-');
        plot(t, y,   'b-');
        plot(t(ii), x(ii), 'm--');
        plot(t(ii), y(ii), 'c--');
      end

      # Fix time drift
      for i=[ip ip+1];
        X{i} = X{i} - dx/dt * (T{i}-T{i}(i1));
        Y{i} = Y{i} - dy/dt * (T{i}-T{i}(i1));
      end
    end
  end

  %%%% 'global' method
  if (strcmp(fix_drift, 'global'))
    # Get time drift for many sweeps.
    # - Find max of lowest current point and min of highest one
    #   in each sweep.
    for i=1:length(I);
      I1(i)=min(I{i}); I2(i)=max(I{i});
    end
    I1 = max(I1); I2=min(I2);


    if (I1>I2) error 'Error: can not compensate time drift, sweeps in different ranges' end

    # - Find t,x,y in these points.
    #   Note that I1 and I2 points correspond to different
    #   parts of the signal and can be shifted.
    for i=1:length(I);
      tm1(i) = interp1(I{i}, T{i}, I1, 'nearest');
      tm2(i) = interp1(I{i}, T{i}, I2, 'nearest');
      xm1(i) = interp1(I{i}, X{i}, I1, 'nearest');
      xm2(i) = interp1(I{i}, X{i}, I2, 'nearest');
      ym1(i) = interp1(I{i}, Y{i}, I1, 'nearest');
      ym2(i) = interp1(I{i}, Y{i}, I2, 'nearest');
    end

    if (drift_plot)
      plot(tm1-tm1(1), xm1, 'r*-');
      plot(tm1-tm1(1), ym1, 'b*-');
      plot(tm2-tm1(1), xm2, 'm*-');
      plot(tm2-tm1(1), ym2, 'c*-');
    end

    # - Fix difference between odd and even points
    ii1 = 1:2:length(tm1);
    ii2 = 2:2:length(tm2);
    # interpolate odd to even and back:
    xm12 = interp1(tm2, xm2, tm1, 'linear');
    xm21 = interp1(tm1, xm1, tm2, 'linear');
    # find difference between odd and even, remove NaN values
    xm12 = xm1-xm12; xm12=xm12(find(!isnan(xm12)));
    xm21 = xm2-xm21; xm21=xm21(find(!isnan(xm21)));
    # calculate mean value and shift data:
    dxm = mean([xm12 -xm21]);
    xm1 = xm1 - dxm/2;
    xm2 = xm2 + dxm/2;

    # same for y:
    ym12 = interp1(tm2, ym2, tm1);
    ym21 = interp1(tm1, ym1, tm2);
    ym12 = ym1-ym12; ym12=ym12(find(!isnan(ym12)));
    ym21 = ym2-ym21; ym21=ym21(find(!isnan(ym21)));
    dym = mean([ym12 -ym21]);
    ym1 = ym1 - dym/2;
    ym2 = ym2 + dym/2;

    [tm, ii] = sort([tm1 tm2]);
    xm=[xm1 xm2](ii);
    ym=[ym1 ym2](ii);

    # Fix time drift during each sweep
    for i=1:length(T);
      dx{i} = interp1(tm, xm, T{i}, 'linear', 'extrap');
      dy{i} = interp1(tm, ym, T{i}, 'linear', 'extrap');
      X{i} = X{i} - dx{i};
      Y{i} = Y{i} - dy{i};
    end
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% fix phase

  if !strcmp(fix_phase, 'none') &&...
     !strcmp(fix_phase, 'first') &&...
     !strcmp(fix_phase, 'last') &&...
     !strcmp(fix_phase, 'average') &&...
     !strcmp(fix_phase, 'separate');
    error('Unknown fix_phase setting, should be "none", "first", "last", "average" or "separate"')
  end

  if verb
    fprintf("Fix phase: %s\n", fix_phase);
  end

  if (!strcmp(fix_phase, 'none') && length(T)>0)
    for i=1:length(T);
      # remove baseline and fix phase
      x1 = X{i}(1); x2 = X{i}(end);
      y1 = Y{i}(1); y2 = Y{i}(end);
      x0(i) = (x1+x2)/2; y0(i)=(y1+y2)/2;
      ph(i)=atan2(y2-y1, x2-x1)*180/3.1415926;
      if (I{i}(end) > I{i}(1)); ph(i)=ph(i)-180; end
    end

    % flatten the phase (before averaging)
    for i=2:length(T);
      if ph(i)-ph(i-1)>180;  ph(i)=ph(i)-360; end
      if ph(i)-ph(i-1)<-180; ph(i)=ph(i)+360; end
    end

    if strcmp(fix_phase, 'first') 
      ph=ones(size(ph))*ph(1);
      x0=ones(size(x0))*x0(1);
      y0=ones(size(y0))*y0(1);
    end

    if strcmp(fix_phase, 'last')
      ph=ones(size(ph))*ph(end);
      x0=ones(size(x0))*x0(end);
      y0=ones(size(y0))*y0(end);
    end

    if strcmp(fix_phase, 'average')
      ph=ones(size(ph))*mean(ph);
      x0=ones(size(x0))*mean(x0);
      y0=ones(size(y0))*mean(y0);
    end

    cp = cos(ph*pi/180);
    sp = sin(ph*pi/180);
    for i=1:length(T);
      x = X{i}-x0(i);
      y = Y{i}-y0(i);
      X{i} =  x*cp(i) + y*sp(i);
      Y{i} = -x*sp(i) + y*cp(i);
      if sum(Y{i})<0 % rotate 180 degrees
        X{i} = -X{i};  Y{i} = -Y{i}; ph(i) = ph(i)+180;
      end
    end

    if (phase_plot)
      find_figure('nmr_get_data: phase'); clf; hold on;
      for i=1:length(T);
        plot(X{i}, Y{i}, 'r-')
        plot(X{i}, Y{i}, 'b.')
      end
    end
    pars.ph = ph;
    pars.x0 = x0;
    pars.y0 = y0;
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get some additional parameters

  if get_freq; pars.freq = get_par(dbpref, 'drydemag_nmr_gen:0', pars.tmean); end
  if get_exc;  pars.exc  = get_par(dbpref, 'drydemag_nmr_gen:1', pars.tmean); end
  if get_com;  pars.exc  = get_par(dbpref, 'drydemag_nmr_gen:3', pars.tmean); end

  if get_grad;  pars.grad = get_par(dbpref, 'drydemag_sweep_grad:0', pars.tmean); end
  if get_quad;  pars.quad = get_par(dbpref, 'drydemag_sweep_quad:0', pars.tmean); end
  if get_helm;  pars.helm = get_par(dbpref, 'drydemag_sweep_helm:0', pars.tmean); end

  if get_temp;  pars.temp = get_par(dbpref, 'drydemag_temp:0', pars.tmean); end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v=get_par(dbpref, dbname, t)
  tp = -1; % previous time value
  v=zeros(size(t));
  for i=length(t):-1:1;
    % copy previous value if nothing had changed
    % (no need to run DB for each point)
    if tp>0 && tp < t(i); v(i) = v(i+1); continue; end

    % get data from dp
    cmd=[dbpref ' get_prev ' dbname ' ' num2str(t(i))];
    [~, data] = system(cmd);
    [tp, v(i)] = strread(data, '%f %f');
  end
end
