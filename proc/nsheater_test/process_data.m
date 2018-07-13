function process_data

  % process heaters.txt + data/*
  % to get information about NS heatleak and HS thermal conductance
  % - time range for each test is extracted
  % - tmix, tstill, pstill, preturn are fit with exponent (with some delay in the beginning)
  % - flow fit with constant (with some delay in the beginning)
  % put information about all cryostat regimes into result.txt
  % put information about all circulations into result_circ.txt

  pkg load optim

  % resistance of heaters:
  Rns=1056;

  % read cruostat data
  [tmixer_t tmixer_v] = textread('data/t_mixer.txt', '%f %f');
  [tns_t tns_v]         = textread('data/t_ns.txt', '%f %f');

  % squid calibration
  tns_v = tns_v/1.0841;

  % read heater data: date, time, set voltages for still, mixer,
  % measured voltages for still, mixer heaters.
  [D T V0N VN ] = textread('heaters.txt', '%s %s %f %f');

  % time shift (between computers, now should be 0)
  sh1=0;
  sh2=0;
  sh2=400;

  % convert date and time to unix seconds
  t=[];
  for i=1:length(D)
    [~,tt] = system(sprintf('date -d "20%s %s" +%%s', D{i}, T{i}));
    t(i) = str2num(tt);
  end

  % prepare plots
  find_figure('NS heating'); clf;
  h(1) = subplot(2,2,1); hold on;
  h(2) = subplot(2,2,2); hold on;
  h(3) = subplot(2,2,[3 4]); hold on;
  title(h(1), 'Tmixer');
  title(h(2), 'Tns');

  % get averaged data
  for i=1:length(D)
    % select measurement range
    t1 = t(i); 
    if (i<length(D)) t2 = t(i+1);
    else t2 = tmixer_t(end); end

    tmixer(i) = fitexp(tmixer_t+sh1, tmixer_v,    t1, t2, 600, h(1));
    tns(i)    = avr(tns_t+sh2,  tns_v,            t1, t2, 1000, h(2));
  end

  QN = (1e6*(VN).^2/Rns); % uW

  ## save data
  ff=fopen('result.txt','w');
  fprintf(ff,'# all equilibrium states (as a function of Qstill, Qmixer)\n');
  fprintf(ff, '#%-7s %-8s %-8s\n',
     'VN[V]', 'Tmix[mK]', 'Tns[mK]');
  for i=1:length(D)
    fprintf(ff, '%8.5f %8.5f %8.5f\n', VN(i), 1000*tmixer(i), 1000*tns(i));
  end
  fclose(ff);

  dT2 = (tns.^2 - tmixer.^2);

  ii=!isnan(dT2);
  dT2=dT2(ii);
  QN=QN(ii);

  p1 = polyfit(QN, dT2', 1);

  xx=[0 max(QN)*1.2];

  plot(h(3), QN, dT2, "r*");
  plot(h(3), xx, polyval(p1, xx),    "r-");
  xlabel('Q, uW');
  ylabel('Tns^2 - Tmix^2, K^2');

  # dT2 = a * QN + b
  # QN + Q0 = K * dT2
  # -> K=1/a, Q0 = b/a
  K  = 1/p1(1);



  #### fit smaller range near zero
  ii=find(QN<1);
  p2 = polyfit(QN(ii), dT2(ii)', 1);
  Q0 = p2(2)/p2(1);

  xx=[-Q0 max(QN(ii))];
  plot(h(3), xx, polyval(p2, xx), "b-");


  L = 2.44e-8; # Lorentz number [W Ohm /K^2];
  fprintf( 'Q_ns = %f [uW]\n', Q0 );
  fprintf( 'K_hs = %f T [W/K]\n', K/1e6 );
  fprintf( 'R_hs = %f [uOhm]\n', 1e6*L/(K/1e6) );



end


function a = avr(t,v, t1,t2, del, pl)
  ii=find(t>=t1 & t<t2);
  jj=find(t>=t1+del & t<t2);
  if (length(jj)<2); a=nan; return; end
  a = mean(v(jj));
  if pl;
    plot(pl, t(ii)-t(1), v(ii));
    plot(pl, [t(jj(1)) t(ii(end))]-t(1), [a a], 'k-')
  end;
end

function a = fitexp(t,v, t1,t2, del, pl)
  ii=find(t>=t1 & t<t2);
  jj=find(t>=t1+del & t<t2);
  if (length(jj)<2); a=nan; return; end
  t1=t(jj(1));
  t2=t(jj(end));
  v1=v(jj(1));
  v2=v(jj(end));
  span=abs(v1-v2);
  ffunc = @(p,x) p(1) + p(2)*exp(-x/p(3));
  p = [v2, v1-v2, (t2-t1)/5 ];
  p1 = [v2-5*span -5*span (t2-t1)/20];
  p2 = [v2+5*span  5*span (t2-t1)/2]; % do not want to fit long exps
  p=lsqcurvefit(ffunc, p, t(jj)-t1, v(jj), p1,p2);

  if pl;
    plot(pl, t(ii)-t(1), v(ii));
    plot(pl, t(jj)-t(1), ffunc(p,t(jj)-t1), 'k-');
  end;
  a=p(1);
end
