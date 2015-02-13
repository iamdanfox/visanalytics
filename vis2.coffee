###

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

###

COLUMN_NAMES = ['1990-1994', '1995-1999', '2000-2004', '2005-2009', '2010-2014']

d3.csv('FreqWords5Year.csv')
  .row( (rawRow) ->
    (['sum'].concat COLUMN_NAMES).map (columnName) ->
      rawRow[columnName] = parseInt(rawRow[columnName], 10)
    rawRow
  )
  .get((error, rows) ->
    # initialisation stuff
    WIDTH = 600
    HEIGHT = 600

    svg = d3.select('#visualisation2').style
      width: WIDTH + 200
      height: HEIGHT + 200
      background: '#444'
      # border: '1px solid #333'

    g = svg.append('g').attr
      'transform': 'translate(70,100)'

    # project data
    grouped = {}
    for colName in COLUMN_NAMES
      grouped[colName] = rows.map((row) -> row[colName]).sort().reverse()

    # rankingDataFn = (row) -> for i in [0..4]
    #   x: i
    #   y: grouped[COLUMN_NAMES[i]].indexOf row[COLUMN_NAMES[i]]

    rawDataFn = (row) -> for i in [0..4]
      x: i
      y: row[COLUMN_NAMES[i]]

    adjustedRows = rows.map (row) ->
      rankingData: rawDataFn(row)
      sum: row.sum
      word: row.word

    horizontalScale = d3.scale.linear().domain([0,4]).range([0, WIDTH - 20])
    verticalOrderingScale = d3.scale.linear().domain([250, 0]).range([0, HEIGHT])
    # verticalOrderingScale = d3.scale.linear().domain([0, rows.length - 1]).range([0, HEIGHT])

    # colourScale = d3.scale.linear().domain([250, 0]).range(['hsl(240, 40%, 90%)', 'hsl(310, 60%, 30%)'])
    colourScale = d3.scale.category20b().domain([250, 0])

    mouseOverLine = (mouseOverRow) ->
      lineColour = 'black'

      circles = g.selectAll('circle.line-highlight').data(mouseOverRow.rankingData)
      circles.enter()
        .append('circle')
        .attr
          'class': 'line-highlight'
          r: 3
          stroke: lineColour
          'stroke-width': 2
      # circles.exit().remove()
      circles.attr
        cx: (point) -> horizontalScale(point.x)
        cy: (point) -> verticalOrderingScale(point.y)

      g.selectAll('text.word').data(adjustedRows)
        .style
          # fill: (row) -> colourScale(row.rankingData[4].y)
          opacity: 0
        .filter (row) -> row is mouseOverRow
        .style
          # fill: 'red'
          opacity: 1

      g.selectAll('path.line').data(adjustedRows)
        .attr
          stroke: (row) -> colourScale(row.rankingData[4].y)
        .filter (row) -> row is mouseOverRow
        .attr
          stroke: lineColour

      # lines = g.select('path').data(row).attr
      #   stroke: 'red'

      # lines.exit().attr
      #   stroke: (row) -> colourScale(row.rankingData[4].y)


    # draw actual lines
    g.selectAll('path')
      .data(adjustedRows)
      .enter()
      .append('path')
      .attr(
        'title': (row) -> row.word
        'class': 'line'
        'd': (row) ->
          (d3.svg.line()
            .interpolate('cardinal')
            .tension(0.8)
            # .interpolate('linear')
            .x (point) -> horizontalScale(point.x)
            .y (point) -> verticalOrderingScale(point.y)
          )(row.rankingData)
        'stroke': (row) -> colourScale(row.rankingData[4].y)
        'stroke-width': 1.8
        'fill': 'none'
      ).on('mouseover', mouseOverLine)
      # .on('mouseout', mouseOutLine)
        # 'opacity': 0.8

    # draw on labels
    g.selectAll('text')
      .data(adjustedRows)
      .enter()
      .append('text')
      .text (row) -> row.word
      .attr
        'class': 'word'
        x: WIDTH + 15
        y: (row) -> verticalOrderingScale(row.rankingData[4].y)
        fill: (row) -> colourScale(row.rankingData[4].y)

    # draw on axes
    brushes = [0..4].map (i) ->
      axis = d3.svg.axis()
        .scale(verticalOrderingScale)
        .orient('right')

      g.append('g')
        .attr
          'class': 'vertical-axis'
          transform: 'translate(' + horizontalScale(i) + ',0)'
        .call(axis)

      brush = d3.svg.brush()
        .y(verticalOrderingScale)

      brushg = g.append('g')
        .attr(
          'class': 'brush'
          'transform': 'translate(' + (horizontalScale(i) - 10) + ',0)'
          'fill': 'rgba(255,0,0,0.2)'
        ).call(brush)

      brushg.selectAll('rect').attr
        width: 40

      return brush

    # brushing behaviour
    rowMatchesBrushes = (row) ->
      for i in [0..4] when not brushes[i].empty()
        [lower, upper] = brushes[i].extent()
        return false unless lower <= row.rankingData[i].y <= upper
      return true

    focusLines = ->
      g.selectAll('path.line, text.word')
        .attr 'opacity': 0.1
        .filter rowMatchesBrushes
        .attr 'opacity': 0.8

    for brush in brushes
      brush.on 'brush', focusLines

    return
  )

