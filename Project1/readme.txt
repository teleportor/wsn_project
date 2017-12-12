0,1,2号节点的node_id分别为19,20,21
接收串口数据，可用java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB0:telosb
接收串口数据并转换成温湿度值输出，可用java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB0:telosb | python3 display.py
（计算公式不知道对不对……）
