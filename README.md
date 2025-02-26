# Curly Quotes
**Curly Quotes** is a MuseScore 3.x/4.x plugin to change apostrophes and quotation marks from straight to curly (also known as “**smart quotes**”). The plugin changes quotation marks in lyrics and other text surrounding the staff (like staff text, system text, expression text, etc.)

## Usage
1. Copy curlyQuotes.qml and/or curlyQuotes-German.qml into your plugins directory. See [MuseScore 4 documentation](https://musescore.org/en/handbook/4/plugins#manage) or [MuseScore 3 documentation](https://musescore.org/en/handbook/3/plugins#install-new) for details.
2. Enable the plugin(s) in MuseScore (**Plugins** > **Plugin Manager**).
3. Optionally select the range the plugin should work on, else it'll work on the entire score. 
4. Choose **Plugins** > **Curly Quotes** resp. **Curly Quotes - German** to convert existing lyrics and other text surrounding the staff. 

## Features

* **Quotes**
  > <big><big>“Hi!”</big></big>

* **Nested quotes**
  > <big><big>“‘Hi,’ he told me,” said Sam.</big></big>

* **Contractions**
  > <big><big>It’s</big></big>

* **Contractions that start with an apostrophe**
  > <big><big>’bout time!</big></big>

## Details
“Smart quotes” as implemented by most programs use only a simple set of rules to determine the direction of the curl:
* If the quotation mark _starts a line_, use a _left_ quote. 
* If the quotation mark _follows a space_, use a _left_ quote.
* Otherwise, use a _right_ quote.

These rules work most of the time, but fail in two circumstances.

1. Contractions like **’neath** and **’tis** should use a normal apostrophe (“right single quote”). 
2. When you have a quotation mark followed by another quotation mark. For instance, nested quotes like, “‘Hi,’ he told me.”

To address the first issue, the Curly Quotes plugin keeps a list of English words that start with an apostrophe (see line 22). When it encounters these words, it adopts the “right single quote” character. These types of contractions are more common in lyrics than other types of writing. 

To address the second issue, the Curly Quotes plugin adapts the second rule: 
* If the quotation mark follows a space _or another quotation mark_, use a left quote. 

