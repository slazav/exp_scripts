function process_data

  % process heaters.txt + data/*
  % to get information about cryostat stable regims.
  % - time range for each test is extracted
  % - tmix, tstill, pstill, preturn are fit with exponent (with some delay in the beginning)
  % - flow fit with constant (with some delay in the beginning)
  % put information about all cryostat regimes into result.txt
  % put information about all circulations into result_circ.txt

  pkg load optim

  % resistance of heaters:
  Rmix=120;
  Rstill=120;

  % read cruostat data
  [tmixer_t tmixer_v] = textread('data/t_mixer.txt', '%f %f');
  [tstill_t tstill_v] = textread('data/t_still.txt', '%f %f');
  [flow_t   flow_v]   = textread('data/flow.txt',    '%f %f');
  [pstill_t pstill_v] = textread('data/p_still.txt', '%f %f');
  [preturn_t preturn_v] = textread('data/p_return.txt', '%f %f');
  [tns_t tns_v]         = textread('data/t_ns.txt', '%f %f');

  % read heater data: date, time, set voltages for still, mixer,
  % measured voltages for still, mixer heaters.
  [D T V0S V0M VS VM ] = textread('heaters.txt', '%s %s %f %f %f %f');

  % reaf squid multiplier
  K = textread('squid_mult.txt', '%f');
  tns_v = tns_v * K(1);

  % time shift (between computers, now should be 0)
  sh=0;

  % convert date and time to unix seconds
  t=[];
  for i=1:length(D)
    [~,tt] = system(sprintf('date -d "20%s %s" +%%s', D{i}, T{i}));
    t(i) = str2num(tt) - sh;
  end

  % prepare plots
  find_figure('delution'); clf;
  h(1) = subplot(3,2,1); hold on;
  h(2) = subplot(3,2,2); hold on;
  h(3) = subplot(3,2,3); hold on;
  h(4) = subplot(3,2,4); hold on;
  h(5) = subplot(3,2,5); hold on;
  h(6) = subplot(3,2,6); hold on;
  title(h(1), 'Tmixer');
  title(h(2), 'Tstill');
  title(h(3), 'Pstill');
  title(h(4), 'Preturn');
  title(h(5), 'Flow');

  % get averaged data
  for i=1:length(D)
    % select measurement range
    t1 = t(i); 
    if (i<length(D)) t2 = t(i+1);
    else t2 = tmixer_t(end); end

    % was still heater changed?
    if i>1 && V0S(i)!=V0S(i-1); Sch=1; else Sch=0; end

    tmixer(i) = fitexp(tmixer_t, tmixer_v,    t1, t2, 600, h(1));
    if Sch
      tstill(i) = fitexp(tstill_t, tstill_v,    t1, t2, 600, h(2));
      pstill(i)  = fitexp(pstill_t, pstill_v,   t1, t2, 300, h(3));
      preturn(i) = fitexp(preturn_t, preturn_v, t1, t2, 300, h(4));
      flow(i)   = avr(flow_t, flow_v,           t1, t2, 600, h(5));
      tns(i)    = avr(tns_t,  tns_v,            t1, t2, 600, h(1));
    else
      tstill(i) = fitexp(tstill_t, tstill_v,    t1, t2, 100, h(2));
      pstill(i)  = avr(pstill_t, pstill_v,      t1, t2, 600, h(3));
      preturn(i) = avr(preturn_t, preturn_v,    t1, t2, 600, h(4));
      flow(i)   = avr(flow_t, flow_v,           t1, t2, 150, h(5));
      tns(i)    = avr(tns_t,  tns_v,            t1, t2, 600, h(1));
    end
  end

  QM = (1e6*(VM).^2/Rmix); % uW
  QS = (1e6*(VS).^2/Rstill); % uW
  T2 = 1e6*tmixer.^2;   % mK^2


  ## save data
  ff=fopen('result.txt','w');
  fprintf(ff,'# all equilibrium states (as a function of Qstill, Qmixer)\n');
  fprintf(ff, '#%-7s %-8s  %-7s %-7s  %-5s  %-8s  %-5s %-5s  %-5s  %-5s\n',
     'VS[V]', 'VM[V]', 'QS[mW]', 'QM[uW]', 'mmol/s', 'PS[mbar]', 'TS[mK]', 'TM[mK]', 'Pret[mbar]', 'Tns[mK]');
  for i=1:length(D)
    fprintf(ff, '%8.5f %8.5f  %7.3f %7.3f  %5.3f  %8.6f  %5.3f %5.3f  %5.3f  %5.3f\n',...
     VS(i), VM(i), 1e-3*QS(i), QM(i), flow(i), pstill(i), 1000*tstill(i), 1000*tmixer(i), preturn(i), 1000*tns(i));
  end
  fclose(ff);

% make linear fit for each circulation
  ff=fopen('result_circ.txt','w');
  fprintf(ff, '# Qstill[mW] T_0[mK] Q_0[uW] Flow[mmol/s] Tstill[mK] Pstill[mbar]\n');
  V=unique(V0S);
  for i=1:length(V)
    ii=find(V0S==V(i) & !isnan(T2') & !isnan(QM));

    if length(ii)<2; continue; end
    plot(h(6), QM(ii), T2(ii), "r*-");
    pp=polyfit(QM(ii), T2(ii)', 1);

    xx=-1:max(QM);
    plot(h(6), xx, polyval(pp,xx), 'b-');
    Q0 = pp(2)/pp(1);
    T0 = sqrt(pp(2));
    if isnan(Q0) || isnan(T0); continue; end
    text(max(QM(ii))+1, max(T2(ii)),...
       sprintf('Qstill = %.2f mW\n Q_0=%.2f uW\n T_0=%.2f mK',mean(QS(ii))/1000, Q0,T0 ));

    fprintf(ff, '%5.2f %5.2f %.3f %.3f %.3f %.4f\n', mean(QS(ii))/1000,T0,Q0, mean(flow(ii)), mean(tstill(ii)), mean(pstill(ii)) );
  end
  fclose(ff)

  xlabel('Qmixer, uW')
  ylabel('T^2, mK^2')
  ylim([0 max(T2)])
end


function a = avr(t,v, t1,t2, del, pl)
  ii=find(t>=t1 & t<t2);
  jj=find(t>=t1+del & t<t2);
  if (length(jj)<2); a=nan; return; end
  a = mean(v(jj));
  if pl;
    plot(pl, t(ii)-t(1), v(ii));
    plot(pl, [t(jj(1)) t(jj(end))]-t(1), [a a], 'k-')
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

