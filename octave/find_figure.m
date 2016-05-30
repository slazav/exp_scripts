function fig = find_figure(figname)
% find figure with given name or create new
% modified script from /rota/programs/matlab

fig = findobj(0,'-depth',1,'Name',figname);
if ~isempty(fig)
  set(0,'CurrentFigure',fig(1));
else
  fig=figure;
  set(fig,'Name',figname);
end

clf; hold on;
