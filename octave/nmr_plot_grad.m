# plot optimal gradient measurements

function nmr_plot_grad(t1, t2)

  [T,I,X,Y] = nmr_get_data(t1,t2);
  [TS,IS,XS,YS] = nmr_get_sweeps(T,I,X,Y);
  [XS,YS] = nmr_fix_drift(TS,IS,XS,YS);
  [XS,YS] = nmr_fix_phase(TS,IS,XS,YS, 1);

  find_figure('nmr_plot_grad'); clf; hold on;


 gg=[];
 mm = 0.2;
  for i=1:1:length(TS);
    dy=round(i/2);
    t = IS{i};
    x = 1.8*XS{i}/mm;
    y = 1.8*YS{i}/mm;
    g = nmr_get_par('grad', TS{i}(1)) * 1000;
    gs = sprintf('%.0f', g);
    plot([t(1) t(end)], dy*[1 1], 'k--');
    plot(t, x+dy, 'b-');
    plot(t, y+dy, 'r-');
    text(t(1), dy+0.1, gs);
    gg(end+1) = g;
  end


  ax1 = gca;
%  ax1_pos = get(ax1, 'Position');
%  ax2 = axes('Position',ax1_pos,...
%    'XAxisLocation','top',...
%    'YAxisLocation','right',...
%    'Color','none');
%
%  for a = [ax1 ax2];
%    set(a, 'YTickMode', 'manual');
%    set(a, 'YTick', round(gg*100)/100);
%  end

  dI = 4e-4;
  Ilim = get(ax1, 'Xlim');
  text(Ilim(1), min(gg)-0.5, [t1 ' - ' t2 ]);

  Xlim = 1e4*(Ilim - mean(Ilim))/mean(Ilim);
  Glim = [min(gg)-1, max(gg)+2];
  xlabel(ax1, "Imain, A")
%  xlabel(ax2, "dB/B x 1e4")
  ylabel(ax1, "Igrad, mA")
#  xlim(ax1, Ilim)
#  xlim(ax2, Xlim)
#  ylim(ax1, Glim)
#  ylim(ax2, [-15 2])
#  title('Field inhomogeneity and effect of gradient coil')



end
