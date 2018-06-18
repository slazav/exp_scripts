% Get NMR data (time, current, x, y) for a time range

function [T,I,X,Y] = nmr_get_data(t1, t2)
  % Get data. Columns: time, Imeas, Iset, Vmeas, X, Y
  data = db_get_range('drydemag_sweep_main', t1, t2, [1 3 5 6]);
  T=data(:,1);
  I=data(:,2);
  X=data(:,3);
  Y=data(:,4);
end
