% Convert date (such as "2018-06-12 19:57:32") to unix time using unix
% date program. Numerical values are returned without conversion:

% All these calls return 1528822652:
% date2unix('2018-06-12 19:57:32')
% date2unix('@1528822652')
% date2unix(1528822652)

function s=date2unix(d)
  if !isnumeric(d);
    [~, s] = system(['date +%s -d "' d '"']);
    s=str2num(s);
  else s=d end
end
