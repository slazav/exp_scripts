% Get some parameter for a given time:
%   grad -- cradient coil current
%   quad -- quadratic coil current
%   freq -- generator frequency
%   exc -- excitation amplitude
%   com -- compensation amplitude

function val = nmr_get_par(name, t)

  if nargin<2; t=''; end
  if length(t)>0; t=date2unix(t); end

  % construct db query
  dbpref='graphene -d /home/exports/DB';
  dbname='';
  if strcmp(name, 'grad'); dbname='drydemag_sweep_grad:0'; end
  if strcmp(name, 'quad'); dbname='drydemag_sweep_quad:0'; end
  if strcmp(name, 'helm'); dbname='drydemag_sweep_helm:0'; end
  if strcmp(name, 'freq'); dbname='drydemag_nmr_gen:0'; end
  if strcmp(name, 'exc');  dbname='drydemag_nmr_gen:1'; end
  if strcmp(name, 'com');  dbname='drydemag_nmr_gen:3'; end
  if strcmp(dbname,''); error(['unknown parameter: ' name]); end
  cmd=[dbpref ' get_prev ' dbname ' ' num2str(t)];

  % run command and parse result
  [~, data] = system(cmd);
  [time, val] = strread(data, '%f %f');
end
