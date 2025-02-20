import QtQuick 2.9
import MuseScore 3.0

MuseScore {
  menuPath: "Plugins." + qsTr("Curly Quotes - German")
  description: "Change apostrophes and double quotes from straight to curly. This plugin can only affect lyric text."
  version: "1.3"

  id: curlyquotes

  //4.4 title: "Curly Quotes - German"
  Component.onCompleted : {
    if (mscoreMajorVersion >= 4 && mscoreMinorVersion <= 3) {
       curlyquotes.title = "Curly Quotes - German";
    }
  }

  onRun: {
    if (!curScore)
      (typeof(quit) === 'undefined' ? Qt.quit : quit)()

    var wordsStartingWithApostrophe = []

    var cursor = curScore.newCursor();
    cursor.rewind(Cursor.SELECTION_START)
    var startStaff
    var endStaff
    var endTick
    var fullScore = false
    if (!cursor.segment) { // no selection
      fullScore = true
      startStaff = 0 // start with 1st staff
      endStaff = curScore.nstaves - 1 // and end with last
    }
    else {
      startStaff = cursor.staffIdx
      cursor.rewind(Cursor.SELECTION_END)
      if (cursor.tick === 0) {
        // this happens when the selection includes
        // the last measure of the score.
        // rewind(Cursor.SELECTION_END)) goes behind the last segment
        // (where there's none) and sets tick=0
        endTick = curScore.lastSegment.tick + 1
      }
      else
        endTick = cursor.tick
      endStaff = cursor.staffIdx
      }
    //console.log(curScore.selection.elements.text)

    //console.log(Lyrics.Syllabic,Element.BEGIN, Syllabic)
    curScore.startCmd();
    for (var staff = startStaff; staff <= endStaff; staff++) {
      for (var voice = 2; voice < 4; voice++) {
        cursor.rewind(Cursor.SELECTION_START) // sets voice to 0
        cursor.voice = voice //voice has to be set after goTo
        cursor.staffIdx = staff

        if (fullScore)
          cursor.rewind(Cursor.SCORE_START) // if no selection, beginning of score

        while (cursor.segment) {

          //
          // Check lyrics
          //
          var e = cursor.element;
          if (e) {
            console.log("type:", e.name, e.element);
            for (var i = 0; i < e.lyrics.length; i++) {
              //console.log(e.lyrics[i].text);

              // Left single quote (exclude words that start with apostrophe)
              if (e.lyrics[i].syllabic <= 1 // SINGLE or BEGIN syllable, not END or MIDDLE
                  && wordsStartingWithApostrophe.indexOf(e.lyrics[i].text.replace("&quot;",'"').replace(/[,.?¿!¡;:"‘’“”‚„‹›«»–— *†‡()\[\]{}\/`]/g,"").replace(/'$/,"")) == -1) { // exclude common contractions that starts with an apostrophe (omit punctuation when checking against word list) 
                e.lyrics[i].text = e.lyrics[i].text.replace(/^'/g,"‚");
                e.lyrics[i].text = e.lyrics[i].text.replace(/(\s|\s&quot;)'/g,"$1‚");
                e.lyrics[i].text = e.lyrics[i].text.replace(/^&quot;'|^“'/g,"“‚");
              }

              // Right single quote or normal apostrophe
              e.lyrics[i].text = e.lyrics[i].text.replace(/'/g,"‘");

              // Left double quote
              e.lyrics[i].text = e.lyrics[i].text.replace(/^&quot;/g,"„");
              e.lyrics[i].text = e.lyrics[i].text.replace(/(\s‘?)&quot;/g,"$1„");
              e.lyrics[i].text = e.lyrics[i].text.replace(/^'&quot;|^‘&quot;/g,"‘„");

              // Right double quote
              e.lyrics[i].text = e.lyrics[i].text.replace(/&quot;/g,"“");
            }
          }
          //
          // Check "annotations"
          //

          for (var i = 0; i < cursor.segment.annotations.length; i++) {
            var a = cursor.segment.annotations[i];
            //console.log(a.name,a.type,a.text)

            if (a.text) {

              // Left single quote (exclude words that start with apostrophe)
              if (wordsStartingWithApostrophe.indexOf(a.text.replace("&quot;",'"').replace(/[,.?¿!¡;:"‘’“”‚„‹›«»–— *†‡()\[\]{}\/`]/g,"").replace(/'$/,"")) == -1) { // exclude common contractions that starts with an apostrophe (omit punctuation when checking against word list) 
                a.text = a.text.replace(/^'/g,"‚");
                a.text = a.text.replace(/(\s|\s&quot;)'/g,"$1‚");
                a.text = a.text.replace(/^&quot;'|^“'/g,"“‚");
              }

              // Right single quote or normal apostrophe
              a.text = a.text.replace(/'/g,"‘");

              // Left double quote
              a.text = a.text.replace(/^&quot;/g,"„");
              a.text = a.text.replace(/(\s‘?)&quot;/g,"$1„");
              a.text = a.text.replace(/^'&quot;|^‘&quot;/g,"‘„");

              // Right double quote
              a.text = a.text.replace(/&quot;/g,"“");
            }
          }

          cursor.next();
        } // end while cursor
      } // end for loop
    } // end for loop
    curScore.endCmd();
    //console.log(curScore.title,curScore.scoreName,curScore.composer) // This pulls the metadata under File > Score Properties rather than the text on the page. 
    //console.log(curScore.parts[0].staff)
    (typeof(quit) === 'undefined' ? Qt.quit : quit)()
  }
}
