
function [x,y,e,bestR, iris_mask]= find_iris_ours(E)
Ycbcr = rgb2ycbcr(E);
e =  edge(Ycbcr(:,:,1),'canny');
%e =  edge(Ycbcr(:,:,1),'sobel');
e = edge(Ycbcr(:,:,1),'zerocross') ; %not bad
e = edge(Ycbcr(:,:,1),'log') ; %not bad
%e = edge(Ycbcr(:,:,1),'roberts'); %good for pupil
R = round((size(E,1)/2).*1.3); 
sizeIm = size(e);
bestR = R;
dr = round((size(E,1)/2).*0.6);
bestFit = 0;
Fit = [];
for i=1:dr
    [x0,y0,HM2] = find_circle(e,R);
    my_circle = getCircleImage(sizeIm,R, x0, y0);
    % we delete circle regions that "horizontal", since lower and upper 
    %iris edges not always found, but the eyelid edge gets instead
    my_circle(:, x0-round(R/2):x0+round(R/2)) = 0;
    circleEdge = e & my_circle;
    X = find(circleEdge);
    if (length(X) > bestFit)
        x = x0;y = y0;
        bestR = R;  
        bestFit = length(X);
    end
    Fit = [Fit length(X)];
    R = R-1;
end
iris_mask = my_circle;


function my_circle = getCircleImage(sizeIm,R, x0, y0)

wrapp_scale = 3;
sizeC = sizeIm.*wrapp_scale;
%ymin, xmin, ymax,xmax
%subWin = 0.5*[(sizeC-sizeIm), (sizeC-sizeIm)];
subWin = [1+sizeIm, 2*sizeIm];
xc = x0+sizeIm(2);
yc = y0+sizeIm(1);

wrapped_circle = zeros(sizeC);
wrapped_circle = MidpointCircle(wrapped_circle, R, xc, yc, 1);
my_circle = wrapped_circle(subWin(1):subWin(3), subWin(2):subWin(4));

function [x0,y0,HM2] = find_circle(I,R)
[y,x]=find(I);
[sy,sx]=size(I);

% 2. Find all the require information for the transformatin. the 'totalpix'
% is the numbers of '1' in the image, while the 'maxrho' is used to find
% the size of the Hough Matrix
totalpix = length(x);

% 3. Preallocate memory for the Hough Matrix. Try to play around with the
% R, or the radius to see the different results.
HM = zeros(sy*sx,1);
R2 = R^2;

% 4. Performing Hough Transform. Notice that no "for-loop" in this portion
% of code.

%%
% a. Preparing all the matrices for the computation without "for-loop"
b = 1:sy;
y = repmat(y',[sy,1]);
x = repmat(x',[sy,1]);

b1 = repmat(b',[1,totalpix]);
b2 = b1;
%%
% b. The equation for the circle
a1 = (round(x - sqrt(R2 - (y - b1).^2)));
a2 = (round(x + sqrt(R2 - (y - b2).^2)));

%%
% c. Removing all the invalid value in matrices a and b
b1 = b1(imag(a1)==0 & a1>0 & a1<sx);
a1 = a1(imag(a1)==0 & a1>0 & a1<sx);
b2 = b2(imag(a2)==0 & a2>0 & a2<sx);
a2 = a2(imag(a2)==0 & a2>0 & a2<sx);

ind1 = sub2ind([sy,sx],b1,a1);
ind2 = sub2ind([sy,sx],b2,a2);

ind = [ind1; ind2];


% d. Reconstruct the Hough Matrix
val = ones(length(ind),1);
data=accumarray(ind,val);
HM(1:length(data)) = data;
HM2 = reshape(HM,[sy,sx]);

%%
% 6. Finding the location of the circle with radius of R
[maxval, maxind] = max(max(HM2));
[B,A] = find(HM2==maxval);
x0 = mean(A);
y0 = mean(B);