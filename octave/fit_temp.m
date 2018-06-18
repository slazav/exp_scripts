# process squid temperature data.
# - no args -- make a plot
# - array arg -- convert time (s) to temperature (K)

function ret=fit_temp(v)
  order     = 2;               % polynom order for fitting
  file_temp = 'data/t_ns.txt'; % file with temperature data
  file_tk   = 'tk.txt';        % file with kink times

  ret=[];

  % read criostat data
  [tns_t, tns_v, ~] = textread(file_temp, '%f %f %f');

  % read kink coordinates
  [tk] = textread(file_tk, '%f');
  tk = [tns_t(1); tk(find(tk>tns_t(1) & tk<tns_t(end))); tns_t(end)];

  t0=tns_t(1);
  tk=(tk-t0)/3600;
  tns_t=(tns_t-t0)/3600;

  % fit data between kinks
  for i=1:length(tk)-1
    ii=find(tns_t>=tk(i) & tns_t<tk(i+1));
    p{i}=polyfit(tns_t(ii), tns_v(ii), order);
  end

  % Adjust kink coordinates to have smooth transitions.
  % Find crossing of two polinoms nearest to the old kink position.
  % Newtons method: x1=x0-f(x0)/f'(x0)
  for i=1:length(p)-1
    pp=p{i}-p{i+1};
    pd=polyder(pp);
    for j=1:5
      tk(i+1) -= polyval(pp,tk(i+1))/polyval(pd,tk(i+1));
    end
  end


  if (nargin==0)
    % prepare plots
    find_figure('ns_temp'); clf; hold on;
    xlabel('time, h');
    ylabel('Tns, mK');

    plot(tns_t/3600, 1e3*tns_v, 'g-')
    for i=1:length(tk)-1
      ii=find(tns_t>=tk(i) & tns_t<tk(i+1));
      plot(tns_t(ii)/3600, 1e3*polyval(p{i},tns_t(ii)), 'b-');
      plot(tk(i)/3600, 1e3*polyval(p{i},tk(i)), 'r*');
      plot(tk(i+1)/3600, 1e3*polyval(p{i},tk(i+1)), 'm*');
      fprintf(' %.6f', t0+tk(i), t0+tk(i+1));
      fprintf(' %13e', p{i});
      fprintf('\n');
    end
  else
    v=(v-t0)/3600;
    for i=1:length(v)
      if v(i)<tk(1) || v(i)>=tk(end); ret(end+1)=NaN; continue; end
      j=find(tk<v(i), 1, 'last');
      ret(end+1)=polyval(p{j}, v(i));
    end
  end

end
