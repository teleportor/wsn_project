0,1,2号节点的node_id分别为19,20,21
接收串口数据，可用java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB0:telosb
接收串口数据并转换成温湿度值输出，可用java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB0:telosb | python3 display.py
（计算公式不知道对不对……）

TODO:解决采样周期过短（如100ms）时数据传输跟不上的问题
(Update:实际上不是数据传输的问题，采集数据用时比发送消息多得多，需要改进采集数据的部分)
TODO:通过计算机重新设置采样频率
TODO:记录数据
TODO:数据可视化
