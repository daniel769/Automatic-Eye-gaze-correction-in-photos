function newImage =  dummyComplete(newim, eye_mask_l);
% retina synthesis for eye completion
[row1,col1] = find(eye_mask_l(:,:,1)==1);
row2 = row1 + dy;
col2 = col1 + dx;

diff = setdiff([row1,col1], [row2,col2], 'rows');

ind = diff(:,1)+(diff(:,2)-1)*r;
newim([ind, ind + r*c,ind + 2*r*c]) = 255;