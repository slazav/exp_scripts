# plot gradient measurements

function nmr_plot_optquad(t1, t2, Ispan, Ip, Gp)

  [T,I,X,Y] = nmr_get_data(t1,t2);
  [TS,IS,XS,YS] = nmr_get_sweeps(T,I,X,Y);
  [XS,YS] = nmr_fix_drift_pairs(TS,IS,XS,YS);
  [XS,YS] = nmr_fix_phase(TS,IS,XS,YS, 0);

  find_figure('nmr_plot_optquad'); clf; hold on;

  plot_frame=(nargin >= 5 && length(Ip)==4 && length(Gp)==4);

  freq = nmr_get_par('freq', T(1))/1000; % freq, kHz
  grad = nmr_get_par('grad', T(1))*1000; % Igrad, mA

  % find maximum of each curve
  for i=1:1:length(TS);
    [am(i), nm(i)] = max(YS{i});
    im(i) = IS{i}(nm(i));
    qq(i) = nmr_get_par('quad', TS{i}(1)) * 1000;
  end
  pp=polyfit(qq,im,1);

  plot_height=40;

  for i=1:2:length(TS);
    t = IS{i};
    x = plot_height*XS{i}/max(abs(XS{i}));
    y = plot_height*YS{i}/max(abs(YS{i}));
    qs = sprintf(' %3.0f', qq(i));
    plot(t-im(i), x+qq(i), 'b-');
    plot(t-im(i), y+qq(i), 'r-');
    plot([t(1) t(end)]-im(i), qq(i)*[1 1], 'b--');
    text(Ispan/2, qq(i), qs)
  end

  text(-Ispan/2.2, min(qq)-5, [t1 ' - ' t2 ', f: ' num2str(freq) ' kHz, Ig: ' num2str(grad) ' mA']);

  Ilim = Ispan*[-1 1]/2;
  Qlim = [min(qq)-10 max(qq)+plot_height];
  xlabel("Imain, A")
  ylabel("Iquad, mA")
  xlim(Ilim)
  ylim(Qlim)
#  title('Field inhomogeneity and effect of gradient coil')
end
