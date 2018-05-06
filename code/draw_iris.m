function draw_iris(e,x0,y0,R)
figure
imshow(e); hold on;
plot(x0,y0,'xr')

t = 0:pi/20:2*pi;
xdata = (x0+R.*cos(t))';
ydata = (y0+R.*sin(t))';
plot(xdata,ydata,'y');
