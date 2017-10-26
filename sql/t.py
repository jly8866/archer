#!/usr/bin/env python
# -*- coding: utf-8 -*-


def compare_items(where_item):

    k = where_item[0]
    v = where_item[1]
    #caution: if v is NULL, may need to process
    if v is None:
        return '`%s` IS %%s' % k

    else:

        return '`%s`=%%s' % k


c={'a':321,'b':'ee','c':{'ll':1}}

print(' and '.join(map(compare_items,c.items())))

print(list(c.values())+list(c.values()))

a = [1,2,3]
b = [4,5,6]
print(a+b)