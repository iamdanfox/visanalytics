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



###
This section defines constants that are independent of the data
###

YEAR_COLUMNS = ['1990-1994', '1995-1999', '2000-2004', '2005-2009', '2010-2014']
AXIS_NAMES = YEAR_COLUMNS.concat ['word']
WIDTH = 600
HEIGHT = 600

HORIZONTAL_SCALE = d3.scale.linear()
  .domain [0, 5]
  .range [0, WIDTH - 20]

FREQ_SCALE = d3.scale.linear()
  .domain [250, 0]
  .range [0, HEIGHT]

COLOUR_SCALE = d3.scale.category20b()
  .domain [250, 0]

MOUSEOVER_LINE_COLOUR = 'black'


###
The following functions return create and return elements of the visualisation.
###

makeVisualisationContainer = ->
  return d3.select '#visualisation2'
    .style
      'width':      WIDTH + 200
      'height':     HEIGHT + 200
      'background': '#444'
    .append 'g'
      .attr
        'transform': 'translate(70, 100)'

makeWordScale = (rows) ->
  return d3.scale.ordinal()
    .domain rows.map (row) -> row.word
    .rangePoints [0, HEIGHT]

# apply horizontal and vertical scales to the data (and convert keys to array)
transformRows = (rows, verticalScales) ->
  return rows.map (row) ->
    coordinates: d3.zip(verticalScales, AXIS_NAMES).map ([scale, axisName], i) ->
      'x': HORIZONTAL_SCALE i
      'y': scale row[axisName]
    word: row.word

makeAxes = (verticalScales) ->
  return verticalScales.map (scale) ->
    d3.svg.axis()
      .scale scale
      .orient 'right'

# returns a brush for each vertical scale, with the correct brushing behaviour all set up
makeBrushes = (g, verticalScales) ->
  brushes = verticalScales.map (scale) ->
    d3.svg.brush().y scale

  rowMatchesAllBrushesPredicate = (row) ->
    return d3.zip row.coordinates, verticalScales, brushes
      .filter ([coordinate, scale, brush]) -> not brush.empty()
      .every ([coordinate, scale, brush]) ->
        y = if scale.invert? then scale.invert coordinate.y else coordinate.y
        [lower, upper] = brush.extent()
        return lower <= y <= upper

  highlightBrushedLines = ->
    g.selectAll 'path.line'
      .attr 'opacity': 0.1
      .filter rowMatchesAllBrushesPredicate
      .attr 'opacity': 0.8

  for brush in brushes
    brush.on 'brush', highlightBrushedLines

  return brushes

# make lines highlight when you hover over one (with nice circles over axis
# intersections), returns a callback
makeMouseoverCallback = (g, transformedRows) ->
  return (mouseOverRow) ->
    circles = g.selectAll 'circle.line-highlight'
      .data mouseOverRow.coordinates
    circles.enter()
      .append 'circle'
      .attr
        'class':        'line-highlight'
        'r':            3
        'stroke':       MOUSEOVER_LINE_COLOUR
        'stroke-width': 2
    circles.attr
      'cx': (point) -> point.x
      'cy': (point) -> point.y

    g.selectAll 'path.line'
      .data transformedRows
      .attr
        'stroke': (row) -> COLOUR_SCALE row.coordinates[4].y
      .filter (row) -> row is mouseOverRow
      .attr
        'stroke': MOUSEOVER_LINE_COLOUR

# nb, this is actually a function now
makePathDFromCoordinates = d3.svg.line()
  .interpolate 'cardinal'
  .tension 0.8
  .x (point) -> point.x
  .y (point) -> point.y



###
The following functions simply draw things onto the specified container `g`
###

drawTextLabels = (g) ->
  g.selectAll 'text.axis-name'
    .data AXIS_NAMES
    .enter()
    .append 'text'
    .text (name) -> name
    .style
      'font-weight': 'bold'
    .attr
      'class': 'axis-name'
      'x':     (name, i) -> HORIZONTAL_SCALE(i) - 15
      'y':     -30
  return

drawLines = (g, transformedRows) ->
  g.selectAll 'path.line'
    .data transformedRows
    .enter()
    .append 'path'
    .on 'mouseover', makeMouseoverCallback(g, transformedRows)
    .attr
      'class':        'line'
      'stroke-width': 1.8
      'fill':         'none'
      'stroke':       (row) -> COLOUR_SCALE row.coordinates[5].y
      'title':        (row) -> row.word
      'd':            (row) -> makePathDFromCoordinates row.coordinates
  return

drawAxes = (g, axes) ->
  for i, axis of axes
    g.append 'g'
      .call axis
      .attr
        'class': 'vertical-axis'
        'transform': 'translate(' + HORIZONTAL_SCALE(i) + ',0)'
  return

drawBrushes = (g, brushes) ->
  for i, brush of brushes
    g.append 'g'
      .call brush
      .attr
        'class': 'brush'
        'transform': 'translate(' + (HORIZONTAL_SCALE(i) - 10) + ',0)'
        'fill': 'rgba(255,0,0,0.2)'
      .selectAll('rect').attr
        'width': 40
  return



###
This section creates as much of the visualisation as we can before the data is loaded
###

g = makeVisualisationContainer()
drawTextLabels(g)



###
Finally, we load the data and create the last parts of the visualisation
###

d3.csv 'FreqWords5Year.csv'
  .row (rawRow) ->
    for columnName in YEAR_COLUMNS
      rawRow[columnName] = parseInt rawRow[columnName], 10
    return rawRow
  .get (error, rows) ->
    console.assert not error?, 'Must load data correctly'

    wordScale = makeWordScale rows
    verticalScales = [FREQ_SCALE, FREQ_SCALE, FREQ_SCALE, FREQ_SCALE, FREQ_SCALE, wordScale]

    transformedRows = transformRows rows, verticalScales
    drawLines g, transformedRows

    axes = makeAxes verticalScales
    drawAxes g, axes

    brushes = makeBrushes g, verticalScales
    drawBrushes g, brushes

