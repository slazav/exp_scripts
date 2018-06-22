% Get NMR data (time, current, x, y) for a time range

function [T,I,X,Y] = nmr_get_data(t1, t2)

  % Get data. Columns: time, Imeas, Iset, Vmeas, X, Y
  % Now db_get_range is very slow!
%  data = db_get_range('drydemag_sweep_main', t1, t2, [1 3 5 6]);
%  T=data(:,1);
%  I=data(:,2);
%  X=data(:,3);
%  Y=data(:,4);

  % convert string dates to unix seconds
  if length(t1)>0; t1=date2unix(t1); end
  if length(t2)>0; t2=date2unix(t2); end

  % construct db query
  dbpref='graphene -d /home/exports/DB';
  dbname='drydemag_sweep_main';
  cmd=[dbpref ' get_range ' dbname ' ' num2str(t1) ' ' num2str(t2)];

  % run command and parse result
  [~, data] = system(cmd);
  [T,IM,I,V,X,Y] = strread(data, '%f %f %f %f %f %f');
end
