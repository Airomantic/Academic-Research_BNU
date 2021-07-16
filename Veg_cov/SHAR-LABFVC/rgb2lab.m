%将图像从rgb色彩空间转换到lab色彩空间
%rgb为输入图像矩阵
function lab=rgb2lab(rgb)
cform=makecform('srgb2lab');
lab=applycform(rgb,cform);