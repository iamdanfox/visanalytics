// Generated by CoffeeScript 1.7.1

/*

LEVEL 1B: Parallel Coordinates Visualization

The software tool at this level should be able to display the tabular data in the spreadsheet named
as “5-years” in FreqWords.xlsx using a parallel coordinates plot. The table includes 5 major data
columns, labelled as “1990-1994”, “1995-1999”, ..., “2000-2014”. Each column has 40 measured
values, that is, 40 multivariate data objects (with five variables). In addition to the five numerical
values, each data object is associated with a nominal value, representing a frequently-occurred
word.

Your software must have the following essential functionality:

 - Display a line for each of the k (20  k  40) data objects, intersecting with the 6 axes at correct places. If you choose k < 40, it is recommended to use the k words with more frequent occurrence.
 - Display labels for each axis.
 - Provide a brushing utility. (Vertical brushing on all)
 - It is recommended to set all five numerical axes to the range [0, 250]. However, you may experiment with other ranges for these axes.
 */
var COLUMN_NAMES;

COLUMN_NAMES = ['1990-1994', '1995-1999', '2000-2004', '2005-2009', '2010-2014'];

d3.csv('FreqWords5Year.csv').row(function(rawRow) {
  (['sum'].concat(COLUMN_NAMES)).map(function(columnName) {
    return rawRow[columnName] = parseInt(rawRow[columnName], 10);
  });
  return rawRow;
}).get(function(error, rows) {
  var HEIGHT, WIDTH, adjustedRows, allWords, brush, brushes, brushg, colourScale, focusLines, g, horizontalScale, mouseOverLine, rawDataFn, rowMatchesBrushes, svg, verticalOrderingScale, wordAxis, wordScale, _i, _len;
  WIDTH = 600;
  HEIGHT = 600;
  svg = d3.select('#visualisation2').style({
    width: WIDTH + 200,
    height: HEIGHT + 200,
    background: '#444'
  });
  g = svg.append('g').attr({
    'transform': 'translate(70,100)'
  });
  horizontalScale = d3.scale.linear().domain([0, 5]).range([0, WIDTH - 20]);
  verticalOrderingScale = d3.scale.linear().domain([250, 0]).range([0, HEIGHT]);
  allWords = rows.map(function(row) {
    return row.word;
  });
  wordScale = d3.scale.ordinal().domain(allWords).range([0, HEIGHT]);
  colourScale = d3.scale.category20b().domain([250, 0]);
  rawDataFn = function(row) {
    var i, timeData;
    timeData = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; _i <= 4; i = ++_i) {
        _results.push({
          x: horizontalScale(i),
          y: verticalOrderingScale(row[COLUMN_NAMES[i]])
        });
      }
      return _results;
    })();
    return timeData.concat([
      {
        x: horizontalScale(5),
        y: wordScale(row.word)
      }
    ]);
  };
  adjustedRows = rows.map(function(row) {
    return {
      rankingData: rawDataFn(row),
      sum: row.sum,
      word: row.word
    };
  });
  mouseOverLine = function(mouseOverRow) {
    var circles, lineColour;
    lineColour = 'black';
    circles = g.selectAll('circle.line-highlight').data(mouseOverRow.rankingData);
    circles.enter().append('circle').attr({
      'class': 'line-highlight',
      r: 3,
      stroke: lineColour,
      'stroke-width': 2
    });
    circles.attr({
      cx: function(point) {
        return point.x;
      },
      cy: function(point) {
        return point.y;
      }
    });
    g.selectAll('text.word').data(adjustedRows).style({
      opacity: 0
    }).filter(function(row) {
      return row === mouseOverRow;
    }).style({
      opacity: 1
    });
    return g.selectAll('path.line').data(adjustedRows).attr({
      stroke: function(row) {
        return colourScale(row.rankingData[4].y);
      }
    }).filter(function(row) {
      return row === mouseOverRow;
    }).attr({
      stroke: lineColour
    });
  };
  g.selectAll('path').data(adjustedRows).enter().append('path').attr({
    'title': function(row) {
      return row.word;
    },
    'class': 'line',
    'd': function(row) {
      return (d3.svg.line().interpolate('cardinal').tension(0.8).x(function(point) {
        return point.x;
      }).y(function(point) {
        return point.y;
      }))(row.rankingData);
    },
    'stroke': function(row) {
      return colourScale(row.rankingData[4].y);
    },
    'stroke-width': 1.8,
    'fill': 'none'
  }).on('mouseover', mouseOverLine);
  g.selectAll('text').data(adjustedRows).enter().append('text').text(function(row) {
    return row.word;
  }).attr({
    'class': 'word',
    x: WIDTH + 15,
    y: function(row) {
      return verticalOrderingScale(row.rankingData[4].y);
    },
    fill: function(row) {
      return colourScale(row.rankingData[4].y);
    }
  });
  brushes = [0, 1, 2, 3, 4].map(function(i) {
    var axis, brush, brushg;
    axis = d3.svg.axis().scale(verticalOrderingScale).orient('right');
    g.append('g').attr({
      'class': 'vertical-axis',
      transform: 'translate(' + horizontalScale(i) + ',0)'
    }).call(axis);
    brush = d3.svg.brush().y(verticalOrderingScale);
    brushg = g.append('g').attr({
      'class': 'brush',
      'transform': 'translate(' + (horizontalScale(i) - 10) + ',0)',
      'fill': 'rgba(255,0,0,0.2)'
    }).call(brush);
    brushg.selectAll('rect').attr({
      width: 40
    });
    return brush;
  });
  wordAxis = d3.svg.axis().scale(wordScale).orient('right');
  g.append('g').attr({
    'class': 'vertical-axis',
    transform: 'translate(' + horizontalScale(5) + ',0)'
  }).call(wordAxis);
  brush = d3.svg.brush().y(verticalOrderingScale);
  brushg = g.append('g').attr({
    'class': 'brush',
    'transform': 'translate(' + (horizontalScale(5) - 10) + ',0)',
    'fill': 'rgba(255,0,0,0.2)'
  }).call(brush);
  brushg.selectAll('rect').attr({
    width: 40
  });
  rowMatchesBrushes = function(row) {
    var i, lower, upper, _i, _ref, _ref1;
    for (i = _i = 0; _i <= 4; i = ++_i) {
      if (!(!brushes[i].empty())) {
        continue;
      }
      _ref = brushes[i].extent(), lower = _ref[0], upper = _ref[1];
      if (!((lower <= (_ref1 = row.rankingData[i].y) && _ref1 <= upper))) {
        return false;
      }
    }
    return true;
  };
  focusLines = function() {
    return g.selectAll('path.line, text.word').attr({
      'opacity': 0.1
    }).filter(rowMatchesBrushes).attr({
      'opacity': 0.8
    });
  };
  for (_i = 0, _len = brushes.length; _i < _len; _i++) {
    brush = brushes[_i];
    brush.on('brush', focusLines);
  }
});
