%输入极化方式polar、入射角theta_i和介电常数epsilon_r实部
function R=DC_R(polar,theta_i,epsilon_r)
%theta_i=55*pi/180
%子函数，计算极化菲涅尔反射系数

if strcmp(polar,'H_pol')==1
    R=(cos(theta_i)-sqrt(epsilon_r-(sin(theta_i))^2))/...
               (cos(theta_i)+sqrt(epsilon_r-(sin(theta_i))^2));
elseif strcmp(polar,'V_pol')==1
        R=(epsilon_r*cos(theta_i)-sqrt(epsilon_r-(sin(theta_i))^2))/...
               (epsilon_r*cos(theta_i)+sqrt(epsilon_r-(sin(theta_i))^2));  
else
    disp('wrong polar input in F_R!');
end



