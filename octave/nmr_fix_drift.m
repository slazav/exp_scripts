% Fix time drift for many sweeps
% Input is cell arrays returned by nmr_get_sweeps.
% Drift is calculated using edge points of each sweep
% and assumed to be a linear function during each sweep.

function [XS YS] = nmr_fix_drift(TS,IS,XS,YS)

  # Get time drift for many sweeps.
  # - Find max of lowest current point and min of highest one
  #   in each sweep.
  for i=1:length(IS);
    I1(i)=min(IS{i}); I2(i)=max(IS{i});
  end
  I1 = max(I1); I2=min(I2);

  if (I1>I2) error 'Error: can not compensate time drift, sweeps in different ranges'

  # - Find t,x,y in these points.
  #   Note that I1 and I2 points correspond to different
  #   parts of the signal and can be shifted.
  for i=1:length(IS);
    tm1(i) = interp1(IS{i}, TS{i}, I1, 'nearest');
    tm2(i) = interp1(IS{i}, TS{i}, I2, 'nearest');
    xm1(i) = interp1(IS{i}, XS{i}, I1, 'nearest');
    xm2(i) = interp1(IS{i}, XS{i}, I2, 'nearest');
    ym1(i) = interp1(IS{i}, YS{i}, I1, 'nearest');
    ym2(i) = interp1(IS{i}, YS{i}, I2, 'nearest');
  end

  if (0)
    fprintf('I1: %f, I2: %f\n', I1, I2);
    find_figure('nmr_fix_drift'); clf; hold on;
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
  for i=1:length(TS);
    dx{i} = interp1(tm, xm, TS{i}, 'linear', 'extrap');
    dy{i} = interp1(tm, ym, TS{i}, 'linear', 'extrap');
    XS{i} = XS{i} - dx{i};
    YS{i} = YS{i} - dy{i};
  end
end
