% Convert unix time to date in "2018-06-12 19:57:32" format

% All these calls return 1528822652:
% date2unix('2018-06-12 19:57:32')
% date2unix('@1528822652')
% date2unix(1528822652)

function d=unix2date(t)
  d=strftime('%Y-%m-%d %H:%M:%S', localtime(t));
end
