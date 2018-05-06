% Draw a circle in a matrix using the integer midpoint circle algorithm
% Does not miss or repeat pixels
% Created by : Peter Bone
% Created : 19th March 2007
function i = MidpointCircle(i, radius, xc, yc, value)

xc = int16(xc);
yc = int16(yc);

x = int16(0);
y = int16(radius);
d = int16(1 - radius);

i(yc+y, xc) = value;
i(yc-y, xc) = value;
i(yc, xc+y) = value;
i(yc, xc-y) = value;

while ( x < y - 1 )
    x = x + 1;
    if ( d < 0 ) 
        d = d + x + x + 1;
    else 
        y = y - 1;
        a = x - y + 1;
        d = d + a + a;
    end
    i( y+yc, x+xc) = value;
    i(  x+yc, y+xc) = value;
    i( -x+yc, y+xc) = value;
    i(-y+yc, x+xc) = value;
    i(-y+yc, -x+xc) = value;
    i(-x+yc, -y+xc) = value;
    i( x+yc, -y+xc) = value;
    i( y+yc, -x+xc) = value;
end
