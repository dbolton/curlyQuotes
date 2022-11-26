import QtQuick 2.0
import MuseScore 3.0

MuseScore {
  menuPath: "Plugins." + qsTr("Curly Quotes for Lyrics")
  description: "Change apostrophes and double quotes from straight to curly. This plugin can only affect lyric text."
  version: "1.0"
  onRun: {
    if (!curScore)
      Qt.quit();

    var wordsStartingWithApostrophe = ["'bout","'cause","'cept","'em","'fro","'n","'neath","'nother","'pon","'re","'round","'s","'sall","'scuse","'sfar","'sup","'thout","'til","'tis","'twas","'tween","'twere","'ve"]
    
    var cursor = curScore.newCursor();
    cursor.voice    = 0;
    cursor.staffIdx = 0;
    cursor.rewind(Cursor.SCORE_START);

    //console.log(Lyrics.Syllabic,Element.BEGIN, Syllabic)
    while (cursor.segment) {
      var e = cursor.element;
      if (e) {
        //console.log("type:", e.name, "at  tick:", e.tick, Element.SINGLE, e.text);
        for (var i = 0; i < e.lyrics.length; i++) {
          //console.log(e.lyrics[i].text);

          //Opening apostrophe (exclude words that start with apostrophe)
          if (e.lyrics[i].syllabic <= 1 // SINGLE or BEGIN syllable, not END or MIDDLE
              && wordsStartingWithApostrophe.indexOf(e.lyrics[i].text.replace("&quot;",'"').replace(/[,.?¿!¡;:"‘’“”‚„‹›«»–— *†‡()\[\]{}\/`]/g,"").replace(/'$/,"")) == -1) { // exclude common contractions that starts with an apostrophe (omit punctuation when checking against word list) 
            e.lyrics[i].text = e.lyrics[i].text.replace(/^'/g,"‘");
            e.lyrics[i].text = e.lyrics[i].text.replace(/(\s|\s&quot;)'/g,"$1‘");
            e.lyrics[i].text = e.lyrics[i].text.replace(/^&quot;'|^“'/g,"“‘");
          }
          
          //Closing apostrophe or normal apostrophe
          e.lyrics[i].text = e.lyrics[i].text.replace(/'/g,"’");
          
          //Opening double quote
          e.lyrics[i].text = e.lyrics[i].text.replace(/^&quot;/g,"“");
          e.lyrics[i].text = e.lyrics[i].text.replace(/(\s‘?)&quot;/g,"$1“");
          e.lyrics[i].text = e.lyrics[i].text.replace(/^'&quot;|^‘&quot;/g,"‘“");
          
          //Closing double quote
          e.lyrics[i].text = e.lyrics[i].text.replace(/&quot;/g,"”");
        }
      }
      cursor.next();
    }
    console.log(curScore.title,curScore.composer) // This pulls the metadata under File > Score Properties rather than the text on the page. 
    Qt.quit();
  }
}