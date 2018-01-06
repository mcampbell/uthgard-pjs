#!/usr/bin/env python

def dow(year, month, day):
    import datetime
    '''Return a day of the week, where 0=Sunday'''
    # weekday() => 0=Monday, 6=Sunday
    # We want      0=Sunday, 6=Saturday
    return [1, 2, 3, 4, 5, 6, 0][datetime.datetime(year, month, day).weekday()]

