% Fix phase in many sweeps
% Input is cell arrays returned by nmr_get_sweeps.
% if separate=0 use a single phase for all sweeps

function [XS YS, ph] = nmr_fix_phase(TS,IS,XS,YS, separate)

  if nargin<5; separate=0; end

 for i=1:length(TS);
    # remove baseline and fix phase
    x1 = XS{i}(1); x2 = XS{i}(end);
    y1 = YS{i}(1); y2 = YS{i}(end);
    x0(i) = (x1+x2)/2; y0(i)=(y1+y2)/2;
    ph(i)=atan2(y2-y1, x2-x1)*180/3.1415926;
    if (IS{i}(end) > IS{i}(1)); ph(i)=ph(i)-180; end
  end

  if separate==0;
    ph=ones(size(ph))*mean(ph);
    x0=ones(size(x0))*mean(x0);
    y0=ones(size(y0))*mean(y0);
  end

  for i=1:length(TS);
    [XS{i}, YS{i}] = nmr_chphase(XS{i}-x0(i), YS{i}-y0(i), ph(i));
    if sum(YS{i})<0 % rotate 180 degrees
      XS{i} = -XS{i};  YS{i} = -YS{i}; ph = ph+180;
    end
  end


  if (1)
    find_figure('nmr_fix_phase'); clf; hold on;
    for i=1:length(TS);
      plot(XS{i}, YS{i}, 'r-')
    end
  end

end
