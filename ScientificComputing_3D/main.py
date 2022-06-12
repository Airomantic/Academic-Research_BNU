
import DEM as dem
import numpy
import os
import PySimpleGUI as ps_GUI
import pandas as pd
from osgeo import gdal
gdal.AllRegister()

'''
蒋宗青 202011069017 地理信息科学
'''

def choose(f_pathName,event,value):

    x, y, window, gaochengcha_matrix, header_dict=dem.ReadFile(f_pathName)
    # 计算坡度
    slope=dem.calculateSlope(x,y)
    # 计算坡向
    aspect=dem.calculateAspect(x,y)
    # 计算晕渲阴影，得到用shaded,ArcMap打开阴影图像
    shaded=dem.calculateDizzyAdamantlyShadow(slope,aspect)

    #获取头部信息
    header=dem.OutHeader(shaded, header_dict)

    #设置九格窗口
    dem.SetNineWindows(slope, aspect, shaded, window, header_dict['NODATA_value'])

    #统计属性
    max_dem, min_dem, mean_dem, list_masked=dem.StatisticsAttribute(gaochengcha_matrix, header_dict['NODATA_value'])
    #海拔高程查排序 注意这是dict还包含着关键字"sort"
    data_sort = dem.ElevationSort(window)
    sort_matrix=data_sort['sort']      #这里是矩阵
    # sortList_values = [i for i in data_sort.values()] # dict转list
    sort_list = sort_matrix.tolist()  # 矩阵转list
    Xmax = len(sort_list)
    # 输出文件
    #分离参数（字典=头部文件，列表=高程差）
    #打印头部文件
    print(header_dict)
    #打印高程差，同时解决打印有省略点的出现（全部打印出来）
    numpy.set_printoptions(threshold=numpy.inf)
    pd.set_option('display.max_rows', None)
    pd.set_option('display.max_columns', None)
    # print(gaochengcha_matrix)
    print("输出文件完成，地形图数据见D:\Data！")
    if event == '查看文件内容':
        if not f_pathName or os.path.exists(f_pathName) == False:
            ps_GUI.popup('未选择文件！！！', text_color='Red')
        else:

            with open(f_pathName) as f:
                #查看内容
                lines = f.readlines()
                f.close()  # 记住要释放
            ps_GUI.popup_scrolled('文件信息', lines)
    if event == '绘制3维空间分布图':
        if not f_pathName or os.path.exists(f_pathName) == False:
            ps_GUI.popup('未选择文件！！！', text_color='Red')
        else:
            # 3d作图 绘制3维图
            rotating_y=int(value['y:'])
            rotating_z=int(value['z:'])
            print(rotating_y,rotating_z)
            if value['4']==True:
                range_ratio1 =10
                range_ratio2=400
            elif value['3']==True:
                range_ratio1 = 225
                range_ratio2 = 320
            elif value['2']==True:
                range_ratio1 = 260
                range_ratio2 = 320
            elif value['1']==True:
                range_ratio1 = 275
                range_ratio2 = 320

            dem.ThreeD(f_pathName,rotating_y,rotating_z,range_ratio1,range_ratio2)
        # 坡度网格写入文件并保存指定路径
    elif event == '计算坡度':
        slope_grid = r"slope.asc"
        # wb   以二进制格式打开一个文件只用于写入，可相继覆盖旧文件
        with open(slope_grid, "wb") as f:
            f.write(bytes(header, "UTF-8"))
            numpy.savetxt(f, slope, fmt="%4i")
        with open(slope_grid) as f:
            # result_slope = f.read()
            result_slope=f.readlines()
        ps_GUI.popup_scrolled('slope坡度如下：', result_slope)

    # 坡向网格
    elif event == '计算坡向':
        aspect_grid = r"aspect.asc"
        with open(aspect_grid, "wb") as f:
            f.write(bytes(header, "UTF-8"))
            numpy.savetxt(f, aspect, fmt="%4i")
        with open(aspect_grid) as f:
            result_aspect = f.read()
            f.close()  # 记住要释放
        ps_GUI.popup_scrolled('aspect坡度如下：', result_aspect)
    #统计高程差属性
    elif event == '查看DEM属性':
        ps_GUI.popup('高程差最大值：%f\n高程差最小值：%f\n平均高程差：%.2f' % (max_dem, min_dem, mean_dem))
    elif event == '将高程差分布排序':
        print(data_sort['sort'])
        ps_GUI.popup_scrolled(data_sort['sort'])
        # ps_GUI.popup_scrolled(data_sort)
    elif event == 'Plot_折线_条形图':
        # Xmax= gaochengcha_matrix.shape[0] * gaochengcha_matrix.shape[1]
        #折线图 条形图
        dem.SortDiagram(sort_list, Xmax)
    elif event=='Plot_频率分布直方图':
        # 频率分布直方图
        dem.SortHistogram(sort_list)
def HanleTIF(f_pathName,event,value):
    if event == '绘制3维空间分布图':
        if not f_pathName or os.path.exists(f_pathName) == False:
            ps_GUI.popup('未选择文件！！！', text_color='Red')
        else:
            # 3d作图 绘制3维图
            rotating_y=int(value['y:'])
            rotating_z=int(value['z:'])
            print(rotating_y,rotating_z)
            if value['4']==True:
                range_ratio1 =10
                range_ratio2=400
            elif value['3']==True:
                range_ratio1 = 225
                range_ratio2 = 320
            elif value['2']==True:
                range_ratio1 = 260
                range_ratio2 = 320
            elif value['1']==True:
                range_ratio1 = 290
                range_ratio2 = 320
            dem.ThreeD(f_pathName,rotating_y,rotating_z,range_ratio1,range_ratio2)