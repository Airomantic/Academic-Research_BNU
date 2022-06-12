
function Depth=Penetration_d(real,imaginary,theta_i,f)

    if nargin<4    
        error('Not enough input arguments.'); 
    elseif nargin>4
        error('Too many input arguments.');
    else 
        %注意因为f的单位为GHz所以取光速3e8/频率=3/f
        E=sqrt(real^2+imaginary^2);
        Depth=3*sqrt(real)*cos(asin(sin(theta_i)/sqrt(E)))/(2*f*pi*imaginary)
    end