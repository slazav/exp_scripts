% Base script for accessing data.
% Get data range t1..t2 from graphene database, return a two-dimentional data array.
% If cols is a non-elpty array then read only columns specified by cols array (1 means time);

function data = db_get_range(dbname, t1, t2, cols)
  % command prefix (system-specific)
  dbpref="graphene -d /home/exports/DB";

%  [data(:,1), ~, data(:,2), ~, data(:,3), data(:,4)] = textread('nmr.txt', '%f %f %f %f %f %f');
%  return

  if nargin < 4; cols=[]; end
  if nargin < 3; t2=''; end
  if nargin < 2; t1=''; end

  if length(t1)>0; t1=date2unix(t1); end
  if length(t2)>0; t2=date2unix(t2); end

  % get data as a string
  cmd=[dbpref ' get_range ' dbname ' ' num2str(t1) ' ' num2str(t2)];
%  ff = popen (cmd, 'r');

  ff=fopen('nmr.txt');

  data=[];
  % for each string
  while (s=fgetl(ff)) != -1;
    v=strread(s);

    if length(v)==0; continue; end

    % read only selected columns (column 1 means time!)
    if length(cols);
      while length(v)<max(cols); v(end+1)=NaN; end
      v=v(cols);
    end

    % put v into data
    if length(data)==0;
      data=v';
    else
      % each line can have different number of records
      % pad data or new line with NaNs id needed:
      while (length(v) > length(data(1,:))); data(:,end+1)=NaN; end
      while (length(v) < length(data(1,:))); v(end+1)=NaN; end
      data(end+1,:)=v;
    end
  end
  fclose(ff);
end
