# plot gradient measurements

function nmr_plot_optgrad(t1, t2, Ispan, Ip, Gp)

  [T,I,X,Y] = nmr_get_data(t1,t2);
  [TS,IS,XS,YS] = nmr_get_sweeps(T,I,X,Y);
  [XS,YS] = nmr_fix_drift(TS,IS,XS,YS);
  [XS,YS] = nmr_fix_phase(TS,IS,XS,YS, 1);

  find_figure('nmr_plot_optgrad'); clf; hold on;

  plot_frame=(nargin >= 5 && length(Ip)==4 && length(Gp)==4);

  freq = nmr_get_par('freq', T(1))/1000; % freq, kHz
  quad = nmr_get_par('quad', T(1))*1000; % Iquad, mA

  main_meas = 405.886; % main coil, G/A (measured)
  grad_calc = 31.4270; % grad coil, G/A/cm (calc)
  cell_height = 0.9;   % cm
  kgrad = (grad_calc*cell_height)/main_meas;

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
    # larmor current: maxmum of highest peak
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
    g = nmr_get_par('grad', TS{i}(1)) * 1000;
    gs = sprintf('%.0f', g);
    plot(x, y+g, 'b-');
    plot([x(1) x(end)], g*[1 1], 'b--');

    if plot_frame;
      ia = i1a + (g-g1a)*k1;
      ib = i1b + (g-g1b)*k2;
      ya = interp1(x,y, ia);
      yb= interp1(x,y, ib);
      plot(ia*[1 1], g+[0, ya], 'b-')
      plot(ib*[1 1], g+[0, yb], 'b-')
    end
    gg(end+1) = g;
  end

  if plot_frame
    k1=-3.5e-3;
    plot(Iopt + 1e-3*(gg-Gopt)*(k1-kgrad/4), gg, 'r--')
    plot(Iopt + 1e-3*(gg-Gopt)*(k1+kgrad/4), gg, 'r--')
  end

  text(Iopt-Ispan/2.2, min(gg)-0.5, [t1 ' - ' t2 ', f: ' num2str(freq) ' kHz, Iq: ' num2str(quad) ' mA']);

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

  axes(ax1)
end
