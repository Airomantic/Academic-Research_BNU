import numpy
from matplotlib import pyplot as plt
#3d
from matplotlib import cm
from matplotlib.colors import LightSource
from osgeo import gdal
gdal.AllRegister()
'''
蒋宗青 202011069017 地理信息科学
'''
#设置全局变量
#高程阴影参数
#日光方位角
Daylight_azimuth=315.0
#日光角度
Daylight_altitude=45.0
#可设高程放大比例，1.0表示没有变化（本次未设置）
z=1.0
#可设分辨率,1.0表示没有变化
scale=1.0

#转化必要参数
degree_radian= 3.141592653589793 / 180.0 #度的弧度
num_degrees= 180.0 / 3.141592653589793 #度数

def ReadFile(pathName):
    # 使用内置的模块循环解析头部信息
    lines=open(pathName).readlines()
    #lines=resource
    header_dict={}
    for i in range(6):
        a,b=lines[i].split()
        header_dict[a]=float(b)
    # header_list = [getline(pathName, i) for i in range(1, 7)]
    # #取出头部属性对应值
    # header_dict_datas = [float(h.split(" ")[-1].strip()) for h in header_list]  # 去掉空格
    # ncols, nrows, xllcorner, yllcorner, cellsize, NODATA_value = header_dict_datas #按文件信息“关键字-数据”的顺序逐个赋值
    cellsize=header_dict['cellsize']
    xres = cellsize
    yres = cellsize * -1

    # numpy加载dem数据（数组）list
    gaochengcha_list = numpy.loadtxt(pathName, skiprows=6) #跳过前6行，从第7行读取
    # 排除围绕边框之外2像素NODATA数据
    # 设置3*3的窗口进行坡度计算
    window = list()
    for row in range(3):
        for column in range(3):
            #3×3逐个九格窗口压入高程差数据到window数组里
            window.append(gaochengcha_list[row:(row + gaochengcha_list.shape[0] - 2), #.shape[0]为矩阵的总行数
                          column:(column + gaochengcha_list.shape[1] - 2)]) #.shape[1]为数组矩阵的总列数
            #| 0 | 1 | 2 |
            #| 3 | 4 | 5 |
            #| 6 | 7 | 8 |
    # 处理水平和竖直方向上3×3模块，采用算法二
    x = ((window[0] + 2*window[3] + window[6]) - (
            window[2] + 2*window[5] + window[8])) / (8.0 * xres)
    y = ((window[6] + 2*window[7] +  window[8]) - (
            window[0] +  2*window[1] +  window[2])) / (8.0 * yres)
    return x,y,window,gaochengcha_list,header_dict

def calculateSlope(x,y):
    # 计算坡度，转换成度数
    slope = numpy.arctan(numpy.sqrt(x **2 + y **2)) * num_degrees
    return slope

def calculateAspect(x,y):
    # 计算坡向
    aspect = numpy.arctan2(x, y)
    return aspect

def calculateDizzyAdamantlyShadow(slope,aspect):
    # 计算晕渲阴影
    shaded = numpy.sin(Daylight_altitude * degree_radian) * numpy.sin(slope * degree_radian) + \
             numpy.cos(Daylight_altitude * degree_radian) * numpy.cos(slope * degree_radian) * \
             numpy.cos((Daylight_azimuth - 90.0) * degree_radian - aspect)
    # 阴影放大比例,可选值区间为：0-1 or 0-255
    shaded = shaded * 255
    return shaded

def SetNineWindows(slope, aspect, shaded, window, NODATA_value):
    # 为窗体设定NODATA值
    for pane in window:
        slope[pane== NODATA_value]=NODATA_value
        aspect[pane == NODATA_value]=NODATA_value
        shaded[pane == NODATA_value]=NODATA_value

def OutHeader(shaded, header_dict):
    # 生成文件中的头部信息
    header = "ncols {}\n".format(shaded.shape[1])
    header += "nrows {}\n".format(shaded.shape[0])
    header += "xllcorner {}\n".format(header_dict['xllcorner'] + (header_dict['cellsize'] * (header_dict['ncols'] - shaded.shape[1])))
    header += "yllcorner {}\n".format(header_dict['yllcorner'] + (header_dict['cellsize'] * (header_dict['nrows'] - shaded.shape[0])))
    header += "cellsize {}\n".format(header_dict['cellsize'])
    header += "NODATA_value {}\n".format(header_dict['NODATA_value'])
    # header += "NODATA_value {}\n".format(0)
    return header

def StatisticsAttribute(gaochengcha_list,NODATA_value):
    list_masked = numpy.ma.masked_where(gaochengcha_list == NODATA_value, gaochengcha_list)
    max_dem = numpy.max(list_masked)
    min_dem = numpy.min(list_masked)
    mean_dem = numpy.mean(list_masked)
    return max_dem, min_dem, mean_dem, list_masked
#字典形式，方便存入文件时一行一行存入并一行一行展示
def ElevationSort(window):
    b=window[0][window[0]>0]
    deminfo={}
    # deminfo['min']=numpy.min(b)
    # deminfo['max']=numpy.max(b)
    # deminfo['mean']=numpy.mean(b)
    deminfo['sort']=numpy.sort(b,axis=None)
    # deminfo=[]
    # deminfo.append(numpy.sort(b,axis=None))
    return deminfo

def SortHistogram(sortList):
    #频率分布直方图
    plt.hist(sortList,20)
    plt.title("Histogram")
    plt.xlabel('district')
    plt.ylabel('frequency')
    plt.show()
def SortDiagram(sortList, Xmax):
    # 条形图
    index = numpy.arange(Xmax)
    plt.bar(x=index, height=sortList, color='green', width=0.5)
    # 折线图
    x = numpy.linspace(1, Xmax, Xmax)  # 第一个高程，最后一个高程，高程数量
    y = sortList
    plt.plot(x, y, linestyle='--', color='red', marker='<')
    plt.show()
def ThreeD(filePath,rotating_y,rotating_z,range_ratio1,range_ratio2):
    dataset = gdal.Open(filePath)
    adfGeoTransform = dataset.GetGeoTransform()
    band = dataset.GetRasterBand(1)  # 用gdal去读写你的数据，当然dem只有一个波段
    # 将高程（海拔值-9999，910～1290）按比例对应相应的像素值0～255
    # 因为-9999到910的落差过大，空间分布图比例不好观察
    ncols = dataset.RasterXSize  # 图像的宽度(X方向上的像素个数) 数据的列数 （这里就是Gdal中的格子和矩阵的不同了）
    nrows = dataset.RasterYSize  # 图像的宽度(Y方向上的像素个数) 数据的行数
    print("列=", ncols, "行=", nrows)
    # 剥离头部和高程数据
    Xmin = adfGeoTransform[0]  # 你的数据的平面四至
    Ymin = adfGeoTransform[3]
    Xmax = adfGeoTransform[0] + nrows * adfGeoTransform[1] + ncols * adfGeoTransform[2]
    Ymax = adfGeoTransform[3] + nrows * adfGeoTransform[4] + ncols * adfGeoTransform[5]  #

    x = numpy.linspace(Xmin, Xmax, ncols)  # 地理x坐标 数组y坐标
    y = numpy.linspace(Ymin, Ymax, nrows)  # 地理y坐标 数组x坐标
    X, Y = numpy.meshgrid(x, y)
    #X=X*1000000000
    #Y=Y*1000000000
    Z = band.ReadAsArray(0, 0, ncols, nrows)  # 这一段就是讲数据的x，y，z化作numpy矩阵（这里Z读取完后是一个Y方向的像素个数*X方向上的像素个数的一个矩阵）

    print(Z)
    print("列=", ncols, "行=", nrows)
    # 将按照"列=",ncols,"行=",nrows
    #若想绘制地形全貌图 请更改设置为 region = numpy.s_[10:400, 10:400]
    region = numpy.s_[range_ratio1:range_ratio2, range_ratio1:range_ratio2]  # 这家伙就等同于一个切片命令，是的没错就这货slice(start, stop, step)

    X, Y, Z = X[region], Y[region], Z[region]  # 数组转置和轴对换：数组不仅有transpose方法，还有一个特殊的T属性比如Z[region].T

    fig, ax = plt.subplots(subplot_kw=dict(projection='3d'),figsize=(12, 10))  # figsize是图幅高宽比例（分辨率），同时随着值都增大，图幅更大更清楚

    ls = LightSource(270, 20)  # 设置你可视化数据的色带
    rgb = ls.shade(Z, cmap=cm.gist_earth, vert_exag=0.1, blend_mode='soft')
    surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, facecolors=rgb,
                           linewidth=0, antialiased=False, shade=False)
    #调整观察角度
    ax.view_init(elev=rotating_y, azim=rotating_z)  # 改变绘制图像的视角,即相机的位置,azim沿着z轴旋转，elev沿着y轴

    plt.show()