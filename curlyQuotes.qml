import QtQuick 2.9
import MuseScore 3.0

MuseScore {
  menuPath: "Plugins." + qsTr("Curly Quotes") + language 
  description: "Change apostrophes and double quotes from straight to curly. This plugin affects lyrics text, system text, staff text, expression text, rehearsal marks, instrument changes, and tempo markings."
  version: "1.3"

  id: curlyquotes

  //4.4 title: "Curly Quotes" + language
  Component.onCompleted : {
    if (mscoreMajorVersion >= 4 && mscoreMinorVersion <= 3) {
       curlyquotes.title = "Curly Quotes" + language;
    }
  }

  property variant wordsStartingWithApostrophe : ["'bout","'cause","'cept","'em","'fro","'n","'neath","'nother","'pon","'re","'round","'s","'sall","'scuse","'sfar","'sup","'thout","'til","'tis","'twas","'tween","'twere","'ve"]

  function changeQuotes(text, type) {
    var t = text;
    // Left single quote (exclude words that start with apostrophe)
    if (type <= 1 // lyrics SINGLE or BEGIN syllable, not END or MIDDLE
        && WordsStartingWithApostrophe.indexOf(t.replace("&quot;", '"').replace(/[,.?¿!¡;:"‘’“”‚„‹›«»–— *†‡()\[\]{}\/`]/g, "").replace(/'$/, "")) == -1) { // exclude common contractions that starts with an apostrophe (omit punctuation when checking against word list)
      t = t.replace(/^'/g,"‘");
      t = t.replace(/(\s|\s&quot;)'/g, "$1‘");
      t = t.replace(/^&quot;'|^“'/g, "“‘");
      }

    // Right single quote or normal apostrophe
    t = t.replace(/'/g, "’");

    // Left double quote
    t = t.replace(/^&quot;/g, "“");
    t = t.replace(/(\s‘?)&quot;/g, "$1“");
    t = t.replace(/^'&quot;|^‘&quot;/g, "‘“");

    // Right double quote
    t = t.replace(/&quot;/g, "”");

    return t;
  }

  onRun: {
    if (!curScore)
      (typeof(quit) === 'undefined' ? Qt.quit : quit)()

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
      for (var voice = 0; voice < 4; voice++) {
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
            //console.log("type:", e.name, e.element);
            for (var i = 0; i < e.lyrics.length; i++) {
              //console.log(e.lyrics[i].syllabic);
              e.lyrics[i].text = changeQuotes(e.lyrics[i].text, e.lyrics[i].syllabic)
            }
          }
          //
          // Check "annotations"
          //
          for (var i = 0; i < cursor.segment.annotations.length; i++) {
            var a = cursor.segment.annotations[i];
            //console.log(a.name, a.type, a.text)

            if (a.text) {
              a.text = changeQuotes(a.text, 2)
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
