function [iris,pupil,out]=find_iris(I,rmin,rmax)
[ci,cp,out]=thresh(I,rmin,rmax);
iris.x0 = ci(2);
iris.y0 = ci(1);
iris.r = ci(3);

pupil.x0 = cp(2);
pupil.y0 = cp(1);
pupil.r = cp(3);