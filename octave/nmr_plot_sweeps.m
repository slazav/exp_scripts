# plot CW sweeps

function nmr_plot_optquad(t1, t2)

  [TS,IS,XS,YS,pars] = nmr_get_data(t1,t2, 'verb', 1, 'sweeps', 1,...
    'sweep_max_r', 0.09,...
    'fix_drift', 'pairs', 'fix_phase', 'separate');

  find_figure('nmr_plot_optquad'); clf; hold on;

  % find maximum of each curve
  for i=1:1:length(TS);
    [xm(i), nm(i)] = max(abs(XS{i}));
    [ym(i), nm(i)] = max(abs(YS{i}));
    im(i) = IS{i}(nm(i));
    [i0(i) Q(i) a0(i) xl(i) xr(i)] = fit_res(IS{i}, YS{i}, 0.5);
  end
  di = (xr-xl)*1e3;
  plot_height=1;


  sh=0;
  for i=1:2:length(TS);
    c = IS{i};
    if (ym(i)<max(ym)/4) continue; end
    x = plot_height*XS{i}/xm(i);
    y = plot_height*YS{i}/ym(i);

    sh = sh + 0.1*mod(i,2);
    plot(c, x+sh, 'b-');
    plot(c, y+sh, 'r-');
    plot([c(1) c(end)], sh*[1 1], 'b--');
    text(max(c), sh, num2str(pars.ph(i)))
  end

  xlabel("dImain, mA")
end
