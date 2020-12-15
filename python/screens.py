import board
import digitalio
from PIL import Image, ImageDraw, ImageFont

class Menu:
    def __init__(self, SC, screen, menu_items):
        self.SC = SC
        self.screen = screen

        self._menu_items = menu_items # copy the menu items and their associated OSC messages
        self._current_item = list(menu_items.keys())[0]
        self._menu_state = {k:v for (k, v) in zip(list(menu_items.keys()), [list(states.keys())[0] for states in list(menu_items.values())])} #the current state of each menu item
        
        self.draw() #init screen

    def up(self):
        print("menu up")
        self._current_item = get_list_neighbor(self._current_item, list(self._menu_items.keys()), shift=-1, wrap=False)
        self.draw()
    
    def down(self):
        print("menu down")
        self._current_item = get_list_neighbor(self._current_item, list(self._menu_items.keys()), shift=1, wrap=False)
        self.draw()
    
    def left(self):
        print("menu left")
        
        current_state = self._menu_state[self._current_item] #find the current state of this menu item
        new_state = get_list_neighbor(current_state, list(self._menu_items[self._current_item].keys()), shift=-1, wrap=True) #find the new one we should shift to
        self._menu_state[self._current_item] = new_state # update the menu state
        
        # Send the new state to supercollider
        osc_msg = self._menu_items[self._current_item][new_state]
        self.SC.sendMsg(*osc_msg)

        self.draw() # update the view

    def right(self):
        print("menu right")
        current_state = self._menu_state[self._current_item] #find the current state of this menu item
        new_state = get_list_neighbor(current_state, list(self._menu_items[self._current_item].keys()), shift=1, wrap=True) #find the new one we should shift to
        self._menu_state[self._current_item] = new_state # update the menu state
        
        # Send the new state to supercollider
        osc_msg = self._menu_items[self._current_item][new_state]
        self.SC.sendMsg(*osc_msg)

        self.draw() # update the view
    
    def select(self, pin): #adding pin here as a temporary hack to get GPIO.add_event_detect call not to throw error (passes pin as arg)
        print("menu select")
        # unused in current revision!

    def draw(self):
        # Create blank image for drawing.
        image = Image.new("1", (self.screen.width, self.screen.height)) # Image mode "1" for 1-bit color

        # Get drawing object to draw on image.
        draw = ImageDraw.Draw(image)

        # Load default font.
        font = ImageFont.load_default()

        # Draw the menu
        ITEM_SPACING = 2 #pixels
        NUM_ITEMS = 5 # that can fit at once

        x = 1
        y = 1

        # find the sublist that we're going to draw
        items = list(self._menu_state.keys())
        current_index = items.index(self._current_item)
        display_start_index = clamp(current_index, 0, len(items) - NUM_ITEMS)
        display_end_index = min(current_index + NUM_ITEMS, len(items))

        items_to_show = items[display_start_index:display_end_index]

        for item in items_to_show:
            if item == self._current_item:
                text = "-{}: < {} >".format(item, self._menu_state[item])
            else:
                text = "{}: {}".format(item, self._menu_state[item])
            
            (_, text_height) = font.getsize(text)

            draw.text(
                (x, y),
                text,
                font=font,
                fill=255,
            )

            y += text_height + ITEM_SPACING

        # Display image
        self.screen.image(image)
        self.screen.show()

    def clear(self):
        self.screen.fill(0)
        self.screen.show()

def get_list_neighbor(item, list_, shift, wrap):
    if wrap:
        return list_[(list_.index(item) + shift) % len(list_)]
    else:
        return list_[clamp(list_.index(item) + shift, 0, len(list_) - 1)]

def clamp(num, min_, max_): #inclusive
    return max(min_, min(num, max_))
