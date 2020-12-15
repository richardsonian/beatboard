def scale(num, oldMin, oldMax, newMin, newMax):
        return (((num - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin

def get_list_neighbor(item, list_, shift, wrap):
    if wrap:
        return list_[(list_.index(item) + shift) % len(list_)]
    else:
        return list_[clamp(list_.index(item) + shift, 0, len(list_) - 1)]

def clamp(num, min_, max_): #inclusive
    return max(min_, min(num, max_))