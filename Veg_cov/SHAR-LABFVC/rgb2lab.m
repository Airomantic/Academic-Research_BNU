%��ͼ���rgbɫ�ʿռ�ת����labɫ�ʿռ�
%rgbΪ����ͼ�����
function lab=rgb2lab(rgb)
cform=makecform('srgb2lab');
lab=applycform(rgb,cform);