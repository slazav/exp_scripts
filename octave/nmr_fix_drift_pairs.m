% Fix time drift for sweep pairs
% Input is cell arrays returned by nmr_get_sweeps.
% Drift is calculated using edge points of each sweep pair
% and assumed to be a linear function during it.

function [XS YS] = nmr_fix_drift_pairs(TS,IS,XS,YS)

  % for each pair
  for ip=1:2:length(IS)-1

    % let's find farthest points in the pair with same current
    i2 = interp1(IS{ip+1}, 1:length(IS{ip+1}), IS{ip}(1), 'nearest');
    i1 = interp1(IS{ip},   1:length(IS{ip}),   IS{ip+1}(end), 'nearest');
    if !isnan(i2)
      i1=1;
    elseif !isnan(i1)
      i2=1;
    else
      error 'Error: nmr_fix_drift_pairs: sweep pair with different ranges?'
    end

    dx = XS{ip+1}(i2)-XS{ip}(i1);
    dy = YS{ip+1}(i2)-YS{ip}(i1);
    dt = TS{ip+1}(i2)-TS{ip}(i1);

    if (0)
      fprintf('I1: %d, I2: %d\n', i1, i2);
      fprintf('dx: %e, dy: %e\n', dx, dy);
      find_figure('nmr_fix_drift_pairs'); clf; hold on;
      plot([TS{ip}; TS{ip+1}] - TS{ip}(1), [XS{ip}; XS{ip+1}],   'r-');
      plot([TS{ip}; TS{ip+1}] - TS{ip}(1), [YS{ip}; YS{ip+1}],   'b-');
      plot([TS{ip}(i1); TS{ip+1}(i2)] - TS{ip}(1), [XS{ip}(i1); XS{ip+1}(i2)], 'r--');
      plot([TS{ip}(i1); TS{ip+1}(i2)] - TS{ip}(1), [YS{ip}(i1); YS{ip+1}(i2)], 'b--');
    end

    # Fix time drift
    for i=[ip ip+1];
      XS{i} = XS{i} - dx/dt * (TS{i}-TS{i}(i1));
      YS{i} = YS{i} - dy/dt * (TS{i}-TS{i}(i1));
    end
  end
end
