class Menu:
    def __init__(self):
        pass

    def up(self):
        print("menu up")
    def down(self):
        print("menu down")
    def left(self):
        print("menu left")
    def right(self):
        print("menu right")
    def select(self, pin): #adding pin here as a hack to get GPIO.add_event_detect call not to throw error (passes pin as arg)
        print("menu select")