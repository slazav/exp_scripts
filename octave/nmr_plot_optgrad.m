# plot gradient measurements

function nmr_plot_optgrad(t1, t2, Ispan, Ip, Gp)
  graphics_toolkit("gnuplot")

  [TS,IS,XS,YS,pars] = nmr_get_data(t1,t2, 'verb', 1, 'sweeps', 1,...
    'fix_drift', 'pairs', 'fix_phase', 'separate',...
    'get_grad', 1, 'get_quad', 1, 'get_freq', 1);

  find_figure('nmr_plot_optgrad'); clf; hold on;
  plot_frame=(nargin >= 5 && length(Ip)==4 && length(Gp)==4);

  main_meas  = 405.886; % main coil, G/A (measured)
  grad_calc  = 31.43/2; % grad coil, G/A/cm (calc)
  grad_const = -3.5e-3; % G/A
  grad_opt   = -7.55; % mA

  cell_height = 0.9;   % cm
  kgrad = (grad_calc*cell_height/2)/main_meas;

  if plot_frame
    i1a=Ip(1); g1a=Gp(1);
    i1b=Ip(2); g1b=Gp(2);
    i2a=Ip(3); g2a=Gp(3);
    i2b=Ip(4); g2b=Gp(4);
    k1=(i2a-i1a)/(g2a-g1a);
    k2=(i2b-i1b)/(g2b-g1b);
    Iopt = ( (g1b-g1a)*k1*k2 + (i1b*k1 - i1a*k2) )/(k1-k2);
    Gopt = g1a + (Iopt-i1a)/k1;
    plot([i1a i2a], [g1a g2a], 'b--');
    plot([i1b i2b], [g1b g2b], 'b--');
  else
    # larmor current: maximum of highest peak
    am=[];
    for i=1:2:length(TS);
      [am(i), nm(i)] = max(YS{i});
      im(i) = IS{i}(nm(i));
    end
    [~, nm] = max(am);
    Iopt = im(nm)
  end

  gg=[];
  for i=1:2:length(TS);
    x = IS{i};
    y = 1.8*abs(YS{i})/max(abs(YS{i}));
    g = pars.grad(i)*1e3;
    gs = sprintf('%.0f', g);
    plot(x, y+g, 'b-');
    plot([x(1) x(end)], g*[1 1], 'b--');

    if plot_frame;
      ia = i1a + (g-g1a)*k1;
      ib = i1b + (g-g1b)*k2;
      ic = (ia+ib)/2;
      ya = interp1(x,y, ia);
      yb= interp1(x,y, ib);
      yc= interp1(x,y, ic);
      plot(ia*[1 1], g+[0, ya], 'b-')
      plot(ib*[1 1], g+[0, yb], 'b-')
      plot(ic*[1 1], g+[0, yc], 'b-')
    end
    gg(end+1) = g;
  end

  if plot_frame
#    plot(Iopt + 1e-3*(gg-grad_opt)*(grad_const-kgrad), gg, 'r--')
#    plot(Iopt + 1e-3*(gg-grad_opt)*(grad_const+kgrad), gg, 'r--')
    plot(Iopt + 1e-3*(gg-grad_opt)*(grad_const), gg, 'b--')
  end

  text(Iopt-Ispan/2.2, min(gg)-0.5, [t1 ', f: ' num2str(pars.freq(1)) ' kHz, Iq: ' num2str(pars.quad(1)*1e3) ' mA']);

  ax1 = gca;
  ax1_pos = get(ax1, 'Position');
  ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

  for a = [ax1 ax2];
    set(a, 'YTickMode', 'manual');
    set(a, 'YTick', round(gg*100)/100);
  end

  dI = 4e-4;
  Ilim = Iopt+Ispan*[-1 1]/2;
  Xlim = 1e4*(Ilim - Iopt)/Iopt;
  Glim = [min(gg)-1, max(gg)+2];
  xlabel(ax2, "dB/B x 1e4")
  xlabel(ax1, "Imain, A")
  ylabel(ax1, "Igrad, mA")
  xlim(ax2, Xlim)
  xlim(ax1, Ilim)
  ylim(ax2, Glim)
  ylim(ax1, Glim)
#  title('Field inhomogeneity and effect of gradient coil')
#  print('-deps',[ num2str(date2unix(t1)) '_grad.eps', 'color'])

  print('-dfig',[ num2str(date2unix(t1)) '_grad.fig'], '-color', '-textspecial')

  axes(ax1)
end
