import re

def get_uint16_t(s):
  search_obj = re.search(r'([0-9A-F]{2}) ([0-9A-F]{2})', s)
  if search_obj:
    high = int(search_obj.group(1), 16)
    low = int(search_obj.group(2), 16)
    return high * 256 + low

while True:
  s = input()
  search_obj = re.search(r'^([0-9A-F]{2} ){8}' +
    '([0-9A-F]{2} [0-9A-F]{2}) ' +
    '([0-9A-F]{2} [0-9A-F]{2}) ' +
    '([0-9A-F]{2} [0-9A-F]{2}) ' +
    '([0-9A-F]{2} [0-9A-F]{2}) ' +
    '([0-9A-F]{2} [0-9A-F]{2})', s)
  if search_obj:
    raw_temp = get_uint16_t(search_obj.group(4))
    raw_humi = get_uint16_t(search_obj.group(5))
    raw_photo = get_uint16_t(search_obj.group(6))
    temp = -40.1 + 0.01 * raw_temp
    humi = -4 + 0.04 * raw_humi - 0.0000028 * raw_humi * raw_humi
    # humi += (temp - 25) * (0.01 + 0.000008 * raw_humi)
    photo = raw_photo
    print('=====================')
    print('Node ID     : %d' % (get_uint16_t(search_obj.group(2))))
    print('Sequence No.: %d' % (get_uint16_t(search_obj.group(3))))
    print('Temperature : %.1f' % (temp))
    print('Humidity    : %.1f%%' % (humi))
    print('Photo       : %d' % (photo))
    #raw_temp = search_obj.group(1)
    #temp = -40.1 + 0.01 * int(raw_temp, 16)
    #print('Temperature: %.2f' % temp)
