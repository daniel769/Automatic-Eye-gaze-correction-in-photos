function [eyeMask, scleraMask, Ibw] = SegmentEye(eyeImage,iris)
Ibw = edge(rgb2gray(eyeImage),'canny',[0.2,0.28],0.25);
figure();imshow(Ibw,[0,1]);

[r,c] = find(Ibw == 1);

ind = find(r == max(r));
max_r = [c(ind(1)),r(ind(1))];

ind = find(r == min(r));
min_r = [c(ind(1)),r(ind(1))];

ind = find(c == max(c));
max_c = [c(ind(1)),r(ind(1))];

ind = find(c == min(c));
min_c = [c(ind(1)),r(ind(1))];

polyDownPts = [min_c;max_c;max_r];
polyUpPts = [min_c;max_c;min_r];

polyDown = polyfit(polyDownPts(:,1),polyDownPts(:,2),2);
polyUp = polyfit(polyUpPts(:,1),polyUpPts(:,2),2);


[r,c,d] = size(eyeImage);

%for testing, draw the parabolas
hold on;
x1 = 1:c; y1 = polyval(polyDown,x1);
plot(x1,y1);

hold on;
x1 = 1:c; y1 = polyval(polyUp,x1);
plot(x1,y1,'r');

[X,Y] = meshgrid(1:c,1:r);
[p1X,p1Y]=find((polyDown(1)*(X.^2) + polyDown(2)*X + polyDown(3) - Y)>0);
p1 = [p1X,p1Y];
[p2X,p2Y]=find((polyUp(1)*(X.^2) + polyUp(2)*X + polyUp(3) - Y)<0);
p2 = [p2X,p2Y];

inters = intersect(p1,p2,'rows');
pX = inters(:,1);
pY = inters(:,2);

newmask = zeros(r,c);
newmask((pY-1)*r+pX) = 1;
figure;imshow(newmask,[0,1]);

eyeMask(:,:,1) =newmask;
eyeMask(:,:,2) =newmask;
eyeMask(:,:,3) =newmask;

%scleraMask
disk = strel('disk', 5);
Ibw = imclose(Ibw, disk);
scleraMask = imfill(Ibw,'holes');
% displays the image on the segmented eye pixels
%eyeMask(:,:,:) = eyeImage(:,:,:).*(repmat(uint8(BW2)./255,[1 1 3]));
%figure(6);
%imshow(uint8(eyeMask));