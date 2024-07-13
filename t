from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.button import Button
from kivy.uix.textinput import TextInput
from kivy.uix.label import Label
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.storage.jsonstore import JsonStore
from kivy.uix.scrollview import ScrollView

# Установим фон окна
from kivy.core.window import Window
Window.clearcolor = (1, 1, 1, 1)

# Хранилище заметок
store = JsonStore('notes.json')

class CalculatorScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.result = TextInput(font_size=32, readonly=True, halign='right', multiline=False, background_color=(0.9, 0.9, 0.9, 1), foreground_color=(0, 0, 0, 1))
        self.formula = ""
        
        self.secret_code = "130724"
        self.input_sequence = ""
        
        layout = BoxLayout(orientation='vertical', padding=10, spacing=10)
        layout.add_widget(self.result)

        buttons = [
            ['C', '(', ')', '/'],
            ['7', '8', '9', '*'],
            ['4', '5', '6', '-'],
            ['1', '2', '3', '+'],
            ['0', '.', 'DEL', '=']
        ]

        button_layout = GridLayout(cols=4, spacing=10, size_hint=(1, 0.7))
        
        for row in buttons:
            for label in row:
                button_layout.add_widget(Button(
                    text=label,
                    on_press=self.on_button_press,
                    background_color=(0.6, 0.6, 0.6, 1) if label in 'C/()*-+=' else (0.8, 0.8, 0.8, 1),
                    color=(0, 0, 0, 1),
                    font_size=24
                ))

        layout.add_widget(button_layout)
        self.add_widget(layout)

    def on_button_press(self, instance):
        current = self.result.text
        button_text = instance.text

        if button_text == "C":
            self.result.text = ""
            self.formula = ""
        elif button_text == "DEL":
            self.result.text = current[:-1]
            self.formula = self.formula[:-1]
        elif button_text == "=":
            try:
                self.result.text = str(eval(self.formula))
            except Exception:
                self.result.text = "Error"
            self.formula = self.result.text
        else:
            if len(self.input_sequence) >= len(self.secret_code):
                self.input_sequence = self.input_sequence[1:] + button_text
            else:
                self.input_sequence += button_text
            
            if self.input_sequence == self.secret_code:
                self.manager.current = 'notes'

            self.result.text += button_text
            self.formula += button_text

class NotesScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation='vertical', padding=10, spacing=10)
        
        self.notes = JsonStore('notes.json')

        self.note_list = BoxLayout(orientation='vertical', size_hint_y=None)
        self.note_list.bind(minimum_height=self.note_list.setter('height'))

        self.scrollview = ScrollView(size_hint=(1, 0.8))
        self.scrollview.add_widget(self.note_list)

        layout.add_widget(Label(text="Заметки", font_size=32, color=(0, 0, 0, 1)))
        layout.add_widget(self.scrollview)

        button_layout = BoxLayout(size_hint=(1, 0.1))
        button_layout.add_widget(Button(text='Новая заметка', on_press=self.new_note))
        button_layout.add_widget(Button(text='Сохранить заметки', on_press=self.save_notes))

        layout.add_widget(button_layout)
        self.add_widget(layout)
        
        self.load_notes()

    def new_note(self, instance):
        note = TextInput(font_size=20, halign='left', multiline=True, size_hint_y=None, height=200, background_color=(0.9, 0.9, 0.9, 1), foreground_color=(0, 0, 0, 1))
        self.note_list.add_widget(note)

    def save_notes(self, instance):
        self.notes.clear()
        for index, note in enumerate(self.note_list.children):
            self.notes.put(str(index), content=note.text)

    def load_notes(self):
        self.note_list.clear_widgets()
        for key in sorted(self.notes.keys()):
            content = self.notes.get(key)['content']
            note = TextInput(font_size=20, halign='left', multiline=True, size_hint_y=None, height=200, text=content, background_color=(0.9, 0.9, 0.9, 1), foreground_color=(0, 0, 0, 1))
            self.note_list.add_widget(note)

class CalculatorApp(App):
    def build(self):
        sm = ScreenManager()
        sm.add_widget(CalculatorScreen(name='calculator'))
        sm.add_widget(NotesScreen(name='notes'))
        return sm

if __name__ == '__main__':
    CalculatorApp().run()










