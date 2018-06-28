function test_nmr_get_data()

  % all sweeps are in the same range
  % for fix_drift=global
  t1="2018-06-28 01:29:23";
  t2="2018-06-28 01:40:48";

  % all sweeps are in the same range, HPD
  % for fix_drift=global
  t1="2018-06-27 01:07:11";
  t2="2018-06-27 02:54:51";


%  t1="2018-06-27 13:21:50";
%  t2="2018-06-27 16:21:00";

  [T,I,X,Y,pars] = nmr_get_data(t1,t2, 'verb', 1,...
    'sweeps', 1, 'sweep_max_r', 0.09, 'sweep_plot', 0,...
    'fix_drift', 'global', 'drift_plot', 0,...
    'fix_phase', 'separate', 'phase_plot', 1,...
    'get_freq', 1, 'get_temp', 1);


  find_figure('test_nmr_get_sweeps'); clf; hold on;

  for i=1:1:length(T);
    plot(pars.tmean-pars.tmean(1), pars.temp, 'b-');
  end



end
