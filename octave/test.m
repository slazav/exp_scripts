function test()

d1='2018-06-12 19:57:32';
d2='2018-06-12 20:35:00';

[T,I,X,Y] = nmr_get_data(d1,d2);

find_figure('nmr'); clf; hold on;
plot(I,X);

end
