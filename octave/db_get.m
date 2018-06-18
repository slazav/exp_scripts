% Base script for accessing data.
% Get data for time t1 from graphene database, return an array with values.
% If cols is a non-elpty array then read only columns specified by cols array (1 means time);

function data = db_get(dbname, t1, cols)
  % command prefix (system-specific)
  dbpref="graphene -d /home/exports/DB";

  if nargin < 3; cols=[]; end
  if nargin < 2; t1=''; end

  if length(t1)>0; t1=date2unix(t1); end

  % get data as a string
  cmd=[dbpref ' get ' dbname ' ' num2str(t1)];
  ff = popen (cmd, 'r');

  data=strread(fgetl(ff))';
  fclose(ff);

  % read only selected columns (column 1 means time!)
  if length(cols);
    while length(data)<max(cols); data(end+1)=NaN; end
    data=data(cols);
  end

end
