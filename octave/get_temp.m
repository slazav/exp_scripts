# process squid temperature data.
# - no args -- make a plot
# - array arg -- convert time (s) to temperature (K)

function ret=fit_temp(v)
  order     = 2;               % polynom order for fitting
  file_temp = 'data/t_ns.txt'; % file with temperature data

  ret=[];

  % read criostat data
  [tns_t, tns_v, ~] = textread(file_temp, '%f %f %f');


  t0=tns_t(1);
  tns_t=(tns_t-t0)/3600;

  if (nargin==0)
    % prepare plots
    find_figure('ns_temp'); clf; hold on;
    xlabel('time, h');
    ylabel('Tns, mK');
    plot(tns_t/3600, 1e3*tns_v, 'g-')
  else
    v=(v-t0)/3600;
    ret=interp1(tns_t, tns_v, v);
  end

end
