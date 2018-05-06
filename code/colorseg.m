function output = colorseg(image)
if nargin == 0,
  image = imread('frontal_view_model.jpg');
  output = colorseg(image);
  output = [];
  return
end
[m,n,p] = size(image);
minI = 0.1;
maxI = 45;
minQ = -1;
maxQ = 0.045;
I = zeros(m,n);
Q = zeros(m,n);
imageYIQ = rgb2ntsc(image);
imageYIQ_I = imageYIQ(:,:,2);
imageYIQ_Q = imageYIQ(:,:,3);
I(find(imageYIQ_I > minI & imageYIQ_I < maxI)) = 1;
Q(find(imageYIQ_Q > minQ & imageYIQ_Q < maxQ)) = 1;
output1 = 255*(I.*Q);
output1 = connect(output1);
output = zeros(m,n,p);
output1 = double(output1);
image = double(image);
output(:,:,1) = output1 .* image(:,:,1);
output(:,:,2) = output1 .* image(:,:,2);
output(:,:,3) = output1 .* image(:,:,3);
imshow(uint8(output));


function output = segmentacija2(image)
I1 = image;
[sx sy sz] = size(I1);
I = rgb2gray(I1);
v1 = edge(I, 'sobel', (graythresh(I) * 0.0377));
%v1 = edge(I, 'prewitt', (graythresh(I) * 0.035));
pv1 = strel('diamond', 2);
v2 = imdilate(v1, pv1);
v3 = imfill(v2, 'holes');
pv3 = strel('diamond',14);
v4 = imerode(v3,pv3);
v4 = imerode(v4,pv3);
output1 = connect(v4);
output = zeros(sx,sy,sz);
output1 = double(output1);
image = double(image);
output(:,:,1) = output1 .* image(:,:,1);
output(:,:,2) = output1 .* image(:,:,2);
output(:,:,3) = output1 .* image(:,:,3);
imshow(uint8(output));


function out = connect(in)
siz = size(in);
lab = bwlabel(in);
h = hist(lab(:),max(lab(:))+1);
[junk, m] = max(h(2:end));
fac = (lab == m);
se = strel('disk',2);
fac = imerode(fac,se);
se = strel('disk',1);
fac2 = fac - imerode(fac,se);
[i,j] = find(fac2 == 1);
k = convhull(j,i);
[X,Y] = meshgrid(1:siz(2),1:siz(1));
out = roipoly(X,Y,in,j(k),i(k));

function sve_koze()
num_faces = 11;
n = 0;
Y = zeros(1,num_faces);
Cb = zeros(1,num_faces);
Cr = zeros(1,num_faces);
for k = 1:num_faces
  filename = sprintf('koza%d.jpg', k);
  RGBface = double(imread(filename));
  YCbCrface = double(rgb2ycbcr(RGBface));
  v1 = uvektor( YCbCrface(:,:,1) );
  m1 = mean(v1);
  s1 = std(v1);
  v2 = uvektor( YCbCrface(:,:,2) );
  m2 = mean(v2); s2 = std(v2);
  v3 = uvektor( YCbCrface(:,:,3) );
  m3 = mean(v3);
  s3 = std(v3);
  n = n + 1;
  Y_s(1,n) = s1;
  Y_m(1,n) = m1;
  Cb_s(1,n) = s2;
  Cb_m(1,n) = m2;
  Cr_s(1,n) = s3;
  Cr_m(1,n) = m3;
end
meanY  = mean(Y_m);
stdY   = mean(Y_s);
meanCb = mean(Cb_m);
stdCb  = mean(Cb_s);
meanCr = mean(Cr_m);
stdCr  = mean(Cr_s);

function  v  = uvektor( mx )
[x y z] = size(mx);
v=zeros(1,x*y);
kk=1;
for i=1:x
  for j=1:y
    v(1,kk)=mx(i,j);
    kk=kk+1;
  end
end

function result=YCbCrbin(RGBimage,meanY,meanCb,meanCr,stdY,stdCb,stdCr,factor)
YCbCrimage=rgb2ycbcr(RGBimage);
[sx,sy,sz] = size (RGBimage);
% set the range of Y,Cb,Cr
min_Cb=meanCb-stdCb*factor;
max_Cb=meanCb+stdCb*factor;
min_Cr=meanCr-stdCr*factor;
max_Cr=meanCr+stdCr*factor;
min_Y=meanY-stdY*factor*2;
max_Y=meanY+stdY*factor*2;
imag_row=size(YCbCrimage,1);
imag_col=size(YCbCrimage,2);

binImage=zeros(imag_row,imag_col);
Cb=zeros(imag_row,imag_col);
Cr=zeros(imag_row,imag_col);
Y(find((YCbCrimage(:,:,1) > min_Y) & (YCbCrimage(:,:,1) < max_Y)))=1;
Cb(find((YCbCrimage(:,:,2) > min_Cb) & (YCbCrimage(:,:,2) < max_Cb)))=1;
Cr(find((YCbCrimage(:,:,3) > min_Cr) & (YCbCrimage(:,:,3) < max_Cr)))=1;
binImage=255*(Cb.*Cr);
result=binImage;
output1 = connect(result);
output = zeros(sx,sy,sz);
output1 = double(output1);
image = double(RGBimage);
output(:,:,1) = output1 .* image(:,:,1);
output(:,:,2) = output1 .* image(:,:,2);
output(:,:,3) = output1 .* image(:,:,3);
imshow(uint8(output));
