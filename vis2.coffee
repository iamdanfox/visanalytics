###

LEVEL 1B: Parallel Coordinates Visualization

The software tool at this level should be able to display the tabular data in the spreadsheet named
as “5-years” in FreqWords.xlsx using a parallel coordinates plot. The table includes 5 major data
columns, labelled as “1990-1994”, “1995-1999”, ..., “2000-2014”. Each column has 40 measured
values, that is, 40 multivariate data objects (with five variables). In addition to the five numerical
values, each data object is associated with a nominal value, representing a frequently-occurred
word.

Your software must have the following essential functionality:

 - Display a line for each of the k (20  k  40) data objects, intersecting with the 6 axes at correct places.
 If you choose k < 40, it is recommended to use the k words with more frequent occurrence.
 - Display labels for each axis.
 - Provide a brushing utility. (Vertical brushing on all)
 - It is recommended to set all five numerical axes to the range [0, 250]. However, you may experiment
 with other ranges for these axes.

###

YEAR_COLUMNS = ['1990-1994', '1995-1999', '2000-2004', '2005-2009', '2010-2014']
NUMBER_COLUMNS = YEAR_COLUMNS.concat('sum')
AXIS_NAMES = YEAR_COLUMNS.concat(['word'])
WIDTH = 600
HEIGHT = 600

HORIZONTAL_SCALE = d3.scale.linear().domain([0,5]).range([0, WIDTH - 20])
COLOUR_SCALE = d3.scale.category20b().domain([250, 0])

makeSvgGroup = ->
  # initialisation stuff
  return d3.select('#visualisation2').style
    width: WIDTH + 200
    height: HEIGHT + 200
    background: '#444'
  .append('g').attr
    'transform': 'translate(70,100)'

transformData = (rows, verticalScales) ->
  rows.map (row) ->
    coordinates: d3.zip(verticalScales, AXIS_NAMES).map ([scale, colName], i) ->
      x: HORIZONTAL_SCALE(i)
      y: scale(row[colName])
    sum: row.sum
    word: row.word

mouseOverLineCallback = (g, transformedData) ->
  # make lines highlight when you hover over one
  return (mouseOverRow) ->
    lineColour = 'black'
    circles = g.selectAll('circle.line-highlight').data(mouseOverRow.coordinates)
    circles.enter()
      .append('circle')
      .attr
        'class': 'line-highlight'
        'r': 3
        'stroke': lineColour
        'stroke-width': 2
    circles.attr
      cx: (point) -> point.x
      cy: (point) -> point.y

    g.selectAll('path.line').data(transformedData)
      .attr
        'stroke': (row) -> COLOUR_SCALE(row.coordinates[4].y)
      .filter (row) -> row is mouseOverRow
      .attr
        'stroke': lineColour

drawPathsOntoSvg = (g, transformedData) ->
  g.selectAll('path')
    .data(transformedData)
    .enter()
    .append('path')
    .attr(
      'title': (row) -> row.word
      'class': 'line'
      'd': (row) ->
        (d3.svg.line()
          .interpolate('cardinal')
          .tension(0.8)
          .x (point) -> point.x
          .y (point) -> point.y
        )(row.coordinates)
      'stroke': (row) -> COLOUR_SCALE(row.coordinates[4].y)
      'stroke-width': 1.8
      'fill': 'none'
    ).on('mouseover', mouseOverLineCallback(g, transformedData))

makeBrushes = (g, verticalScales) ->
  brushes = verticalScales.map (scale) -> d3.svg.brush().y(scale)

  # brushing behaviour
  rowMatchesAllBrushes = (row) ->
    return d3.zip row.coordinates, verticalScales, brushes
      .filter ([data,scale,brush]) -> not brush.empty()
      .every ([data,scale,brush]) ->
        [lower, upper] = brush.extent()
        transform = if scale.invert? then scale.invert else (x) -> x
        return lower <= transform( data.y ) <= upper

  focusLines = ->
    g.selectAll('path.line')
      .attr 'opacity': 0.1
      .filter rowMatchesAllBrushes
      .attr 'opacity': 0.8

  for brush in brushes
    brush.on 'brush', focusLines

  return brushes

drawBrushesAndAxes = (g, brushes, axes) ->
  d3.zip(brushes, axes).map ([brush, axis], i) ->
    g.append('g').attr(
      'class': 'vertical-axis'
      'transform': 'translate(' + HORIZONTAL_SCALE(i) + ',0)'
    ).call(axis)

    g.append('g')
      .call(brush)
      .attr
        'class': 'brush'
        'transform': 'translate(' + (HORIZONTAL_SCALE(i) - 10) + ',0)'
        'fill': 'rgba(255,0,0,0.2)'
      .selectAll('rect').attr
        'width': 40

drawTextLabels = (g) ->
  g.selectAll('text.axis-name')
    .data(AXIS_NAMES)
    .enter()
    .append('text')
    .text (name) -> name
    .style 'font-weight': 'bold'
    .attr
      'class': 'axis-name'
      'x': (name, i) -> HORIZONTAL_SCALE(i) - 15
      'y': -30


g = makeSvgGroup()
drawTextLabels(g)


d3.csv('FreqWords5Year.csv')
  .row (rawRow) ->
    NUMBER_COLUMNS.map (columnName) -> rawRow[columnName] = parseInt(rawRow[columnName], 10)
    rawRow
  .get (error, rows) ->
    # define verticalScales
    frequencyScale = d3.scale.linear().domain([250, 0]).range([0, HEIGHT])
    wordScale = d3.scale.ordinal().domain(rows.map (row) -> row.word).rangePoints([0, HEIGHT])
    verticalScales = [frequencyScale, frequencyScale, frequencyScale, frequencyScale, frequencyScale, wordScale]

    # transform data
    transformedData = transformData(rows, verticalScales)

    # draw actual lines, link to mouseOver behaviour
    drawPathsOntoSvg(g, transformedData)

    # brushes and axes
    brushes = makeBrushes(g, verticalScales)
    axes = verticalScales.map (scale) -> d3.svg.axis().scale(scale).orient('right')
    drawBrushesAndAxes(g, brushes, axes)
