# plot gradient measurements

function nmr_plot_optquad(t1, t2)

  [TS,IS,XS,YS,pars] = nmr_get_data(t1,t2, 'verb', 1, 'sweeps', 1,...
    'sweep_max_r', 0.09,...
    'fix_drift', 'pairs', 'fix_phase', 'separate',...
    'get_grad', 1, 'get_quad', 1, 'get_helm', 1, 'get_freq', 1);

  find_figure('nmr_plot_optquad'); clf; hold on;

  gg = pars.grad * 1e3;
  qq = pars.quad * 1e3;
  hh = pars.helm * 1e3;
  freq = pars.freq(1);

  % find maximum of each curve
  for i=1:1:length(TS);
    [xm(i), nm(i)] = max(abs(XS{i}));
    [ym(i), nm(i)] = max(abs(YS{i}));
    im(i) = IS{i}(nm(i));
    [i0(i) Q(i) a0(i) xl(i) xr(i)] = fit_res(IS{i}, YS{i}, 0.5);
  end
  di = (xr-xl)*1e3;
  plot_height=1;


  f=fopen([t1 '.txt'],'w');

  sh=0;
  for i=1:2:length(TS);
    c = (IS{i} - i0(i))*1e3;
    if (ym(i)<max(ym)/4) continue; end
    x = plot_height*XS{i}/xm(i);
    y = plot_height*YS{i}/ym(i);

%    if (di(i) < 0.1)
      fprintf(f, '%7.2f %7.2f %7.2f  %5.3f %.6f\n', gg(i), qq(i), hh(i), (xr(i)-xl(i))*1e3, i0(i))
%    end

%    if (round(gg(i))!=-6) continue; end

    qs = sprintf(' %3.0f', qq(i));
    hs = sprintf(' %3.0f', hh(i));
    gs = sprintf(' %3.0f', gg(i));
    sh = sh + 0.1;
%    plot(c, x+sh, 'b-');
    plot(c, y+sh, 'r-');
    plot([c(1) c(end)], sh*[1 1], 'b--');
    text(c(end), sh, [gs ' ' qs ' ' hs])
  end
  fclose(f);

fprintf("PH: %f\n", mean(pars.ph));

  text(c(1), min(qq)-5, [t1 ' - ' t2 ', f: ' num2str(freq) ' kHz']);

%  Ilim = Ispan*[-1 1]/2;
#  Qlim = [min(qq)-10 max(qq)+plot_height];
  xlabel("dImain, mA")
%  xlim(Ilim)
#  ylim(Qlim)
#  title('Field inhomogeneity and effect of gradient coil')
end
